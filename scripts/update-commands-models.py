#!/usr/bin/env python3
"""Update commands.json model placeholder lists from OpenCode and Pi.

Preserves existing effort assignments and model order. Adds new models
(base name only, no effort variants). Removes models no longer available.
"""

import json
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
    "none": 0,
    "minimal": 1,
    "low": 2,
    "medium": 3,
    "high": 4,
    "xhigh": 5,
    "max": 6,
}


def should_exclude(name: str, patterns: list[re.Pattern[str]]) -> bool:
    return any(p.search(name) for p in patterns)


def parse_model_entry(entry: str) -> tuple[str, str | None]:
    parts = entry.split(":", 1)
    return parts[0], parts[1] if len(parts) > 1 else None


def merge_models(current: list[str], available: set[str]) -> tuple[list[str], set[str], set[str]]:
    existing: dict[str, list[tuple[str | None, str]]] = {}
    for entry in current:
        base, effort = parse_model_entry(entry)
        existing.setdefault(base, []).append((effort, entry))

    new_list: list[str] = []
    seen: set[str] = set()

    for base in existing:
        if base not in available:
            continue
        seen.add(base)
        entries = existing[base]
        entries.sort(key=lambda x: EFFORT_ORDER.get(x[0], 99) if x[0] else -1)
        for _, entry in entries:
            new_list.append(entry)

    for name in sorted(available - seen):
        new_list.append(name)

    return new_list, set(existing.keys()) - available, available - set(existing.keys())


def get_opencode_models() -> set[str]:
    result = subprocess.run(
        ["opencode", "models"],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "opencode models failed")
    names = set()
    for line in result.stdout.strip().split("\n"):
        line = line.strip()
        if line and not should_exclude(line, OPENCODE_EXCLUDE):
            names.add(line)
    return names


def get_pi_models() -> set[str]:
    result = subprocess.run(
        ["pi", "--list-models"],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "pi --list-models failed")
    names = set()
    for line in result.stdout.strip().split("\n"):
        line = line.strip()
        if not line or line.lower().startswith("provider"):
            continue
        parts = line.split()
        if len(parts) < 2:
            continue
        name = f"{parts[0]}/{parts[1]}"
        if not should_exclude(name, PI_EXCLUDE):
            names.add(name)
    return names


def update_command(data: dict, key: str, available: set[str], label: str) -> None:
    current = data["commands"][key]["placeholders"]["model"]
    new_list, removed, added = merge_models(current, available)
    data["commands"][key]["placeholders"]["model"] = new_list
    changes = []
    if removed:
        changes.append(f"removed {len(removed)}")
    if added:
        changes.append(f"added {len(added)}")
    print(f"{label}: {len(new_list)} variants ({', '.join(changes) or 'no changes'})")


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
