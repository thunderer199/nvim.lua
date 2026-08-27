#!/usr/bin/env python3
"""Update commands.json model lists from the Pi catalog and OpenCode Go docs.

Non-Go providers keep their existing order; new models are appended.
opencode-go models are restricted to the $60 usage bucket and sorted by
requests-per-5h (descending) from https://opencode.ai/docs/go/.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
COMMANDS_JSON = REPO / "commands.json"

GO_DOCS_URL = "https://opencode.ai/docs/go/"
GO_PROVIDER = "opencode-go"
GO_BUCKET = "$60"

PI_EXCLUDE = [
    re.compile(r"^opencode/"),
    re.compile(r"^openai-codex/.+-(?:fast|spark|pro)"),
]

EXTENDED_THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"]

EFFORT_ORDER = {level: i for i, level in enumerate(EXTENDED_THINKING_LEVELS)}


def should_exclude(name: str, patterns: list[re.Pattern[str]]) -> bool:
    return any(p.search(name) for p in patterns)


def parse_model_entry(entry: str) -> tuple[str, str | None]:
    parts = entry.split(":", 1)
    return parts[0], parts[1] if len(parts) > 1 else None


def sort_efforts(efforts: list[str]) -> list[str]:
    return sorted(set(efforts), key=lambda e: (EFFORT_ORDER.get(e, 99), e))


def expand(base: str, efforts: list[str]) -> list[str]:
    if not efforts:
        return [base]
    return [f"{base}:{effort}" for effort in sort_efforts(efforts)]


def fetch_go_catalog() -> dict[str, dict]:
    """Scrape the Go docs for bucket ($/month usage) and requests per 5h."""
    req = urllib.request.Request(
        GO_DOCS_URL, headers={"User-Agent": "Mozilla/5.0 (update-commands-models)"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        html = resp.read().decode()

    def rows(pattern: str) -> list[list[str]]:
        out = []
        for row in re.findall(r"<tr>(.*?)</tr>", html, flags=re.S):
            cells = [
                re.sub(r"<[^>]+>", "", c).strip()
                for c in re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", row, flags=re.S)
            ]
            if cells and cells[0] != "Model":
                out.append(cells)
        return out

    # display name -> model id (endpoints table)
    ids = {}
    for cells in rows(r"<t[dh][^>]*>(.*?)</t[dh]>"):
        if len(cells) >= 4 and cells[1].startswith(tuple("abcdefghijklmnopqrstuvwxyz0123456789")) and "opencode.ai/zen/go" in cells[2]:
            ids[cells[0]] = cells[1]

    # display name -> requests per 5h (usage limits table)
    per5h = {}
    for cells in rows(r"<t[dh][^>]*>(.*?)</t[dh]>"):
        if len(cells) == 4 and re.fullmatch(r"[\d,]+", cells[1] or ""):
            per5h[cells[0]] = int(cells[1].replace(",", ""))

    # display name (without context-window/peak qualifiers) -> usage bucket
    buckets = {}
    for cells in rows(r"<t[dh][^>]*>(.*?)</t[dh]>"):
        if len(cells) == 6 and re.fullmatch(r"\$\d+", cells[-1] or ""):
            name = re.sub(r"\s*\([^)]*\)", "", cells[0])
            buckets[name] = cells[-1]

    catalog: dict[str, dict] = {}
    for name, model_id in ids.items():
        if name in buckets and name in per5h:
            catalog[f"{GO_PROVIDER}/{model_id}"] = {
                "bucket": buckets[name],
                "per5h": per5h[name],
            }
    return catalog


def go_model_lists(
    catalog: dict[str, dict],
    efforts: dict[str, list[str]],
    pi_models: dict[str, list[str]],
) -> tuple[list[str], dict[str, list[str]]]:
    """Return $60-bucket entries sorted by requests/5h desc, and their efforts."""
    bucket_models = [
        (name, info["per5h"])
        for name, info in catalog.items()
        if info["bucket"] == GO_BUCKET and name in pi_models
    ]
    bucket_models.sort(key=lambda item: (-item[1], item[0]))
    entries: list[str] = []
    for name, _ in bucket_models:
        entries.extend(expand(name, efforts.get(name, [])))
    available = {name: efforts.get(name, []) for name, _ in bucket_models}
    return entries, available


def get_pi_models() -> dict[str, list[str]]:
    result = subprocess.run(
        ["pi", "--list-models"],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "pi --list-models failed")

    names: list[str] = []
    for line in result.stdout.splitlines():
        line = line.strip()
        if not line or line.lower().startswith("provider"):
            continue
        parts = line.split()
        if len(parts) < 2:
            continue
        name = f"{parts[0]}/{parts[1]}"
        if not should_exclude(name, PI_EXCLUDE):
            names.append(name)

    levels = load_pi_thinking_levels()
    return {name: levels.get(name, []) for name in names}


def load_pi_thinking_levels() -> dict[str, list[str]]:
    """Return supported thinking levels per model using Pi's own algorithm.

    Replicates getSupportedThinkingLevels() from pi-ai/models.js:
    - reasoning=false -> ["off"]
    - reasoning=true, missing map -> ["off","minimal","low","medium","high"]
    - a level is dropped only if its map entry is explicitly null;
      xhigh/max are also dropped when absent from the map.
    """
    root = Path(os.environ.get("PI_CODING_AGENT_DIR") or Path.home() / ".pi/agent")
    store = root / "models-store.json"
    if not store.is_file():
        return {}
    try:
        data = json.loads(store.read_text())
    except json.JSONDecodeError:
        return {}

    levels: dict[str, list[str]] = {}
    for provider, payload in data.items():
        models = payload.get("models") if isinstance(payload, dict) else None
        if not isinstance(models, list):
            continue
        for model in models:
            if not isinstance(model, dict) or not model.get("id"):
                continue
            name = f"{provider}/{model['id']}"
            if not model.get("reasoning"):
                levels[name] = ["off"]
                continue
            mapping = model.get("thinkingLevelMap") or {}
            supported: list[str] = []
            for level in EXTENDED_THINKING_LEVELS:
                if level in mapping:
                    if mapping[level] is None:
                        continue  # explicitly disabled
                else:
                    if level in ("xhigh", "max"):
                        continue  # absent -> unsupported
                supported.append(level)
            levels[name] = supported
    return levels


def merge_models(
    current: list[str],
    available: dict[str, list[str]],
    go_entries: list[str] | None = None,
) -> tuple[list[str], set[str], set[str]]:
    """Merge models into the placeholder list.

    With go_entries, the list is rebuilt as: sorted Go entries first, then
    non-Go providers in their existing order (new non-Go models appended).
    """
    if go_entries is not None:
        other: list[str] = []
        seen_other: set[str] = set()
        for entry in current:
            base, _ = parse_model_entry(entry)
            if base.startswith(f"{GO_PROVIDER}/"):
                continue
            if base not in seen_other:
                seen_other.add(base)
                if base in available:
                    other.extend(expand(base, available[base]))

        for base in sorted(set(available) - seen_other):
            if not base.startswith(f"{GO_PROVIDER}/"):
                other.extend(expand(base, available[base]))

        return go_entries + other, set(), set()

    existing_order: list[str] = []
    seen: set[str] = set()
    for entry in current:
        base, _ = parse_model_entry(entry)
        if base not in seen:
            existing_order.append(base)
            seen.add(base)

    new_list: list[str] = []
    for base in existing_order:
        if base not in available:
            continue
        new_list.extend(expand(base, available[base]))

    added = set(available) - seen
    for base in sorted(added):
        new_list.extend(expand(base, available[base]))

    return new_list, seen - set(available), added


def update_command(
    data: dict,
    key: str,
    available: dict[str, list[str]],
    label: str,
    go_entries: list[str] | None = None,
) -> None:
    current = data["commands"][key]["placeholders"]["model"]
    new_list, removed, added = merge_models(current, available, go_entries)
    data["commands"][key]["placeholders"]["model"] = new_list
    changes = []
    if removed:
        changes.append(f"removed {len(removed)}")
    if added:
        changes.append(f"added {len(added)}")
    with_effort = sum(1 for efforts in available.values() if efforts)
    print(
        f"{label}: {len(new_list)} entries, "
        f"{len(available)} models, {with_effort} with effort "
        f"({', '.join(changes) or 'catalog refreshed'})"
    )


def main():
    with open(COMMANDS_JSON) as f:
        data = json.load(f)

    pi_models = get_pi_models()
    current = data["commands"]["pi-commit"]["placeholders"]["model"]

    try:
        catalog = fetch_go_catalog()
        efforts = load_pi_thinking_levels()
        go_entries, go_available = go_model_lists(catalog, efforts, pi_models)
        print(
            f"Go: {len(catalog)} models in catalog, "
            f"{len(go_available)} in {GO_BUCKET} bucket"
        )
    except Exception as exc:
        # Keep the existing Go entries untouched if the docs can't be fetched.
        print(f"Go: failed ({exc}); keeping current Go list", file=sys.stderr)
        go_entries = [e for e in current if e.startswith(f"{GO_PROVIDER}/")]

    available = {
        name: efforts for name, efforts in pi_models.items()
        if not name.startswith(f"{GO_PROVIDER}/")
    }

    update_command(data, "pi-commit", available, "Pi", go_entries)

    with open(COMMANDS_JSON, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


if __name__ == "__main__":
    main()
