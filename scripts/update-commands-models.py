#!/usr/bin/env python3
"""Update commands.json model placeholder list from `opencode models`.

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

EXCLUDE_PATTERNS = [
    re.compile(r"-free$"),
    re.compile(r"^opencode/"),
    re.compile(r"^openai/.+-(?:fast|spark|pro)"),
    re.compile(r"^xai/grok-imagine"),  # imaging models unused in Open Code
]


def should_exclude(name: str) -> bool:
    return any(p.search(name) for p in EXCLUDE_PATTERNS)


def get_available_models() -> set[str]:
    result = subprocess.run(
        ["opencode", "models"],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        print(f"Error: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    names = set()
    for line in result.stdout.strip().split("\n"):
        line = line.strip()
        if line and not should_exclude(line):
            names.add(line)
    return names


def parse_model_entry(entry: str) -> tuple[str, str | None]:
    parts = entry.split(":", 1)
    return parts[0], parts[1] if len(parts) > 1 else None


def main():
    with open(COMMANDS_JSON) as f:
        data = json.load(f)

    current = data["commands"]["ai-commit"]["placeholders"]["model"]
    available = get_available_models()

    # Build mapping: base_model -> [(effort, original_entry)]
    existing: dict[str, list[tuple[str | None, str]]] = {}
    for entry in current:
        base, effort = parse_model_entry(entry)
        existing.setdefault(base, []).append((effort, entry))

    new_list: list[str] = []
    seen = set()

    def get_effort_order(effort: str | None) -> int:
        order = {"none": 0, "low": 1, "medium": 2, "high": 3, "xhigh": 4, "max": 5}
        return order.get(effort, 99) if effort else -1

    # For each base model in current list, keep if still available
    for base in list(existing.keys()):
        entries = existing[base]
        if base not in available:
            continue
        seen.add(base)
        entries.sort(key=lambda x: get_effort_order(x[0]))
        for _, entry in entries:
            new_list.append(entry)

    # Add new models (alphabetical)
    for name in sorted(available - seen):
        new_list.append(name)

    data["commands"]["ai-commit"]["placeholders"]["model"] = new_list

    with open(COMMANDS_JSON, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    removed = set(existing.keys()) - available
    added = available - set(existing.keys())
    changes = []
    if removed:
        changes.append(f"removed {len(removed)}")
    if added:
        changes.append(f"added {len(added)}")
    print(f"Updated {COMMANDS_JSON.name}: {len(new_list)} variants ({', '.join(changes)})")


if __name__ == "__main__":
    main()
