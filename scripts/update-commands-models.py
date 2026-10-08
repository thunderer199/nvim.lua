#!/usr/bin/env python3
"""Update commands.json model lists from the Pi catalog and OpenCode Go docs.

Non-Go providers keep their existing order; new models are appended.
opencode-go models are filtered by requests-per-5h threshold and sorted
by requests-per-5h (descending) from https://opencode.ai/docs/go/.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
COMMANDS_JSON = REPO / "commands.json"

GO_DOCS_URL = "https://opencode.ai/docs/go/"
GO_PROVIDER = "opencode-go"
GO_REQ5H_THRESHOLD = 3000

PI_EXCLUDE = [
    re.compile(r"^opencode/"),
    re.compile(r"^(?:azure-)?openai"),
]

EXTENDED_THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"]

EFFORT_ORDER = {level: i for i, level in enumerate(EXTENDED_THINKING_LEVELS)}


def should_exclude(name: str, patterns: list[re.Pattern[str]]) -> bool:
    return any(p.search(name) for p in patterns)


def parse_model_entry(entry: str | dict) -> tuple[str, str | None]:
    if isinstance(entry, dict):
        entry = str(entry.get("value") or "")
    parts = str(entry).split(":", 1)
    return parts[0], parts[1] if len(parts) > 1 else None


def sort_efforts(efforts: list[str]) -> list[str]:
    return sorted(set(efforts), key=lambda e: (EFFORT_ORDER.get(e, 99), e))


def expand(
    base: str, efforts: list[str], display: str | None = None
) -> list[dict[str, str]]:
    title = display or base
    if not efforts:
        return [{"label": title, "value": base}]
    return [
        {"label": f"{title} {effort}", "value": f"{base}:{effort}"}
        for effort in sort_efforts(efforts)
    ]


def normalize_model_name(name: str) -> str:
    """Align Pi display names with Go docs names (punctuation / '(New)')."""
    name = re.sub(r"\([^)]*\)", "", name).lower()
    return re.sub(r"[^a-z0-9]+", "", name)


def _strip_html(fragment: str) -> str:
    fragment = re.sub(r"<br\s*/?>", "\n", fragment, flags=re.I)
    return re.sub(r"<[^>]+>", "", fragment)


def _parse_req5h(cell_html: str) -> int | None:
    """Current requests/5h; promo rows strike the old value and bold the new one."""
    strong = re.findall(r"<strong>(.*?)</strong>", cell_html, flags=re.S | re.I)
    text = _strip_html(strong[-1] if strong else cell_html)
    line = next((part.strip() for part in reversed(text.splitlines()) if part.strip()), "")
    if re.fullmatch(r"[\d,]+", line):
        return int(line.replace(",", ""))
    if "unlimited" in line.lower():
        return sys.maxsize
    return None


def fetch_go_catalog() -> dict[str, int]:
    """Scrape estimated requests per 5h from the Go docs, keyed by display name."""
    req = urllib.request.Request(
        GO_DOCS_URL, headers={"User-Agent": "Mozilla/5.0 (update-commands-models)"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        html = resp.read().decode()

    per5h: dict[str, int] = {}
    for row in re.findall(r"<tr>(.*?)</tr>", html, flags=re.S):
        raw_cells = re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", row, flags=re.S)
        if len(raw_cells) != 4:
            continue
        name = _strip_html(raw_cells[0]).splitlines()[0].strip()
        req5h = _parse_req5h(raw_cells[1])
        if name and req5h is not None:
            per5h[name] = req5h
    return per5h


def go_model_lists(
    catalog: dict[str, int],
    efforts: dict[str, list[str]],
    pi_models: dict[str, list[str]],
    pi_names: dict[str, str],
) -> tuple[list[dict[str, str]], dict[str, list[str]]]:
    """Return Pi Go entries above the requests/5h threshold, sorted desc.

    Quota rows on the website are keyed by display name, not API id
    (`deepseek-v4.1-flash` vs Pi's `deepseek-flash`).
    """
    quota_by_name = {
        normalize_model_name(name): req5h for name, req5h in catalog.items()
    }
    qualifying: list[tuple[str, int]] = []
    for key in pi_models:
        if not key.startswith(f"{GO_PROVIDER}/"):
            continue
        display = pi_names.get(key)
        if not display:
            continue
        req5h = quota_by_name.get(normalize_model_name(display))
        if req5h is None or req5h < GO_REQ5H_THRESHOLD:
            continue
        qualifying.append((key, req5h))
    qualifying.sort(key=lambda item: (-item[1], item[0]))
    entries: list[dict[str, str]] = []
    for name, _ in qualifying:
        entries.extend(expand(name, efforts.get(name, []), pi_names.get(name)))
    available = {name: efforts.get(name, []) for name, _ in qualifying}
    return entries, available


PI_MODULE = "@earendil-works/pi-coding-agent/dist/bundle/cli.js"


def pi_command() -> list[str]:
    """Return the argv prefix to run pi, falling back to the npm global module
    if the `pi` launcher is missing from PATH."""
    pi = shutil.which("pi")
    if pi:
        return [pi]
    npm_root = subprocess.run(
        ["npm", "root", "-g"], capture_output=True, text=True, timeout=30
    )
    if npm_root.returncode == 0:
        cli = Path(npm_root.stdout.strip()) / PI_MODULE
        if cli.is_file():
            return ["node", str(cli)]
    raise RuntimeError("pi executable not found")


def refresh_pi_models() -> None:
    """Force Pi to refresh its model catalog (models-store.json) first,
    otherwise pi --list-models can serve a stale cache missing new models."""
    result = subprocess.run(
        pi_command() + ["update", "--models"],
        capture_output=True, text=True, timeout=120,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "pi update --models failed")


def get_pi_models() -> dict[str, list[str]]:
    refresh_pi_models()
    result = subprocess.run(
        pi_command() + ["--list-models"],
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


def load_models_store() -> dict:
    root = Path(os.environ.get("PI_CODING_AGENT_DIR") or Path.home() / ".pi/agent")
    store = root / "models-store.json"
    if not store.is_file():
        return {}
    try:
        data = json.loads(store.read_text())
    except json.JSONDecodeError:
        return {}
    return data if isinstance(data, dict) else {}


def iter_store_models(data: dict):
    for provider, payload in data.items():
        models = payload.get("models") if isinstance(payload, dict) else None
        if not isinstance(models, list):
            continue
        for model in models:
            if isinstance(model, dict) and model.get("id"):
                yield f"{provider}/{model['id']}", model


def load_pi_display_names() -> dict[str, str]:
    """Return provider/id -> display name from Pi's models store."""
    names: dict[str, str] = {}
    for key, model in iter_store_models(load_models_store()):
        names[key] = str(model.get("name") or model["id"])
    return names


def load_pi_thinking_levels() -> dict[str, list[str]]:
    """Return supported thinking levels per model using Pi's own algorithm.

    Replicates getSupportedThinkingLevels() from pi-ai/models.js:
    - reasoning=false -> ["off"]
    - reasoning=true, missing map -> ["off","minimal","low","medium","high"]
    - a level is dropped only if its map entry is explicitly null;
      xhigh/max are also dropped when absent from the map.
    """
    levels: dict[str, list[str]] = {}
    for name, model in iter_store_models(load_models_store()):
        if not model.get("reasoning"):
            levels[name] = ["off"]
            continue
        mapping = model.get("thinkingLevelMap") or {}
        supported: list[str] = []
        for level in EXTENDED_THINKING_LEVELS:
            if level in mapping:
                if mapping[level] is None:
                    continue
            else:
                if level in ("xhigh", "max"):
                    continue
            supported.append(level)
        levels[name] = supported
    return levels


def merge_models(
    current: list,
    available: dict[str, list[str]],
    go_entries: list[dict[str, str]] | None = None,
    pi_names: dict[str, str] | None = None,
) -> tuple[list[dict[str, str]], set[str], set[str]]:
    """Merge models into the placeholder list.

    With go_entries, the list is rebuilt as: sorted Go entries first, then
    non-Go providers in their existing order (new non-Go models appended).
    """
    names = pi_names or {}
    if go_entries is not None:
        other: list[dict[str, str]] = []
        seen_other: set[str] = set()
        for entry in current:
            base, _ = parse_model_entry(entry)
            if base.startswith(f"{GO_PROVIDER}/"):
                continue
            if base not in seen_other:
                seen_other.add(base)
                if base in available:
                    other.extend(expand(base, available[base], names.get(base)))

        for base in sorted(set(available) - seen_other):
            if not base.startswith(f"{GO_PROVIDER}/"):
                other.extend(expand(base, available[base], names.get(base)))

        return go_entries + other, set(), set()

    existing_order: list[str] = []
    seen: set[str] = set()
    for entry in current:
        base, _ = parse_model_entry(entry)
        if base not in seen:
            existing_order.append(base)
            seen.add(base)

    new_list: list[dict[str, str]] = []
    for base in existing_order:
        if base not in available:
            continue
        new_list.extend(expand(base, available[base], names.get(base)))

    added = set(available) - seen
    for base in sorted(added):
        new_list.extend(expand(base, available[base], names.get(base)))

    return new_list, seen - set(available), added


def group_entries(entries: list) -> list[tuple[str, list[str], list[int]]]:
    """Collapse effort variants: base id -> (display, efforts, positions)."""
    groups: dict[str, tuple[str, list[str], list[int]]] = {}
    for pos, entry in enumerate(entries):
        base, effort = parse_model_entry(entry)
        display, efforts, positions = groups.setdefault(
            base, (str(entry.get("label") or base).rstrip(), [], [])
        )
        if effort:
            efforts.append(effort)
            display = display[: display.rfind(f" {effort}")]
        positions.append(pos)
    return [(base, *rest) for base, rest in sorted(groups.items())]


def diff_report(before: list, after: list) -> str:
    """Human-readable diff of placeholder entries, grouped by model."""
    old, new = group_entries(before), group_entries(after)
    old_map = {base: (name, eff, pos) for base, name, eff, pos in old}
    new_map = {base: (name, eff, pos) for base, name, eff, pos in new}

    lines: list[str] = []
    added = [b for b in new_map if b not in old_map]
    removed = [b for b in old_map if b not in new_map]
    moved = [
        b for b in new_map
        if b in old_map and old_map[b][2] != new_map[b][2]
    ]
    if added:
        lines.append("added:")
        for base in added:
            name, efforts, _ = new_map[base]
            levels = f" [{', '.join(efforts)}]" if efforts else ""
            lines.append(f"  + {name} ({base}){levels}")
    if removed:
        lines.append("removed:")
        for base in removed:
            name, efforts, _ = old_map[base]
            lines.append(f"  - {name} ({base})")
    if moved:
        lines.append("moved:")
        for base in moved:
            name, efforts, _ = new_map[base]
            was = old_map[base][2][0]
            now = new_map[base][2][0]
            lines.append(f"  ~ {name} ({base}) {was} -> {now}")
    return "\n".join(lines) if lines else "no model changes"


def update_command(
    data: dict,
    key: str,
    available: dict[str, list[str]],
    label: str,
    go_entries: list[dict[str, str]] | None = None,
    pi_names: dict[str, str] | None = None,
) -> None:
    current = data["commands"][key]["placeholders"]["model"]
    new_list, removed, added = merge_models(current, available, go_entries, pi_names)
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
    report = diff_report(current, new_list)
    print(f"{label} diff:\n{report}")


def main():
    with open(COMMANDS_JSON) as f:
        data = json.load(f)

    pi_models = get_pi_models()
    pi_names = load_pi_display_names()

    go_entries = None
    try:
        catalog = fetch_go_catalog()
        efforts = load_pi_thinking_levels()
        go_entries, go_available = go_model_lists(
            catalog, efforts, pi_models, pi_names
        )
        print(
            f"Go: {len(catalog)} models in catalog, "
            f"{len(go_available)} above {GO_REQ5H_THRESHOLD} req/5h"
        )
    except Exception as exc:
        # Keep the existing Go entries untouched if the docs can't be fetched.
        print(f"Go: failed ({exc}); keeping current Go list", file=sys.stderr)
        go_entries = [
            e
            for e in data["commands"]["pi-commit"]["placeholders"]["model"]
            if parse_model_entry(e)[0].startswith(f"{GO_PROVIDER}/")
        ]

    available = {
        name: efforts for name, efforts in pi_models.items()
        if not name.startswith(f"{GO_PROVIDER}/")
    }

    update_command(data, "pi-commit", available, "Pi", go_entries, pi_names)

    with open(COMMANDS_JSON, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


if __name__ == "__main__":
    main()
