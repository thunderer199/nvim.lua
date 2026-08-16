#!/usr/bin/env python3
"""Update commands.json model lists from OpenCode and Pi catalogs.

Reads live model ids and their thinking/effort variants. Keeps existing
model order. Adds new models. Removes models no longer available.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
COMMANDS_JSON = REPO / "commands.json"

OPENCODE_EXCLUDE = [
    re.compile(r"-free$"),
    re.compile(r"^opencode/"),
    re.compile(r"^openai/.+-(?:fast|spark|pro)"),
    re.compile(r"^xai/grok-imagine"),
    re.compile(r"^xai/.+-fast"),
]

PI_EXCLUDE = [
    re.compile(r"-free$"),
]

EFFORT_ORDER = {
    "off": 0,
    "none": 1,
    "minimal": 2,
    "low": 3,
    "medium": 4,
    "high": 5,
    "xhigh": 6,
    "max": 7,
    "thinking": 8,
}

MODEL_LINE = re.compile(r"^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$")


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


def merge_models(
    current: list[str],
    available: dict[str, list[str]],
) -> tuple[list[str], set[str], set[str]]:
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


def get_opencode_models() -> dict[str, list[str]]:
    result = subprocess.run(
        ["opencode", "models", "--verbose"],
        capture_output=True, text=True, timeout=60,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "opencode models failed")
    models: dict[str, list[str]] = {}
    lines = result.stdout.splitlines()
    i = 0
    while i < len(lines):
        name = lines[i].strip()
        i += 1
        if not MODEL_LINE.fullmatch(name):
            continue
        while i < len(lines) and not lines[i].strip():
            i += 1
        if i >= len(lines) or not lines[i].lstrip().startswith("{"):
            data: dict = {}
        else:
            buf: list[str] = []
            depth = 0
            while i < len(lines):
                buf.append(lines[i])
                depth += lines[i].count("{") - lines[i].count("}")
                i += 1
                if depth <= 0:
                    break
            data = json.loads("\n".join(buf))
        if should_exclude(name, OPENCODE_EXCLUDE):
            continue
        variants = data.get("variants") or {}
        efforts = list(variants) if isinstance(variants, dict) else []
        models[name] = efforts
    return models


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
            mapping = model.get("thinkingLevelMap")
            if not isinstance(mapping, dict):
                continue
            efforts = [key for key, value in mapping.items() if value is not None]
            if efforts:
                levels[name] = efforts
    return levels


def update_command(data: dict, key: str, available: dict[str, list[str]], label: str) -> None:
    current = data["commands"][key]["placeholders"]["model"]
    new_list, removed, added = merge_models(current, available)
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

    errors = 0
    try:
        update_command(data, "ai-commit", get_opencode_models(), "OpenCode")
    except Exception as exc:
        errors += 1
        print(f"OpenCode: skipped ({exc})", file=sys.stderr)

    try:
        update_command(data, "pi-commit", get_pi_models(), "Pi")
    except Exception as exc:
        errors += 1
        print(f"Pi: skipped ({exc})", file=sys.stderr)

    with open(COMMANDS_JSON, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
