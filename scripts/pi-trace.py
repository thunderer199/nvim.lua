#!/usr/bin/env python3
"""Run `pi --mode json` and print a tool/text transcript plus usage.

With no args and stdin piped, formats a JSONL event stream instead.
"""

from __future__ import annotations

import json
import subprocess
import sys
import time
from typing import Any


def content_text(value: Any) -> str:
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        if value.get("type") == "text":
            return str(value.get("text") or "")
        return content_text(value.get("content"))
    if isinstance(value, list):
        return "".join(content_text(item) for item in value)
    return ""


def tool_label(name: str, args: Any) -> str:
    if not isinstance(args, dict):
        return name
    if name == "bash" and args.get("command"):
        return f"bash  {args['command']}"
    if name in {"read", "edit", "write"} and args.get("path"):
        return f"{name}  {args['path']}"
    if name == "grep" and args.get("pattern"):
        path = args.get("path") or args.get("glob") or ""
        suffix = f"  {path}" if path else ""
        return f"grep  {args['pattern']}{suffix}"
    if args:
        return f"{name}  {json.dumps(args, ensure_ascii=False)}"
    return name


def n(usage: dict, *keys: str) -> float:
    cur: Any = usage
    for key in keys:
        if not isinstance(cur, dict):
            return 0
        cur = cur.get(key)
    if isinstance(cur, (int, float)):
        return cur
    return 0


class Tracer:
    def __init__(self) -> None:
        self.usages: list[dict] = []
        self.model: str | None = None
        self.provider: str | None = None
        self.failed = False
        self._partial: dict[str, str] = {}
        self._need_nl = False

    def _write(self, text: str, end: str = "\n") -> None:
        if self._need_nl and text:
            sys.stdout.write("\n")
            self._need_nl = False
        sys.stdout.write(text)
        sys.stdout.write(end)
        sys.stdout.flush()

    def handle(self, event: dict) -> None:
        kind = event.get("type")
        if kind == "tool_execution_start":
            call_id = str(event.get("toolCallId") or "")
            self._partial[call_id] = ""
            self._write(f"▸ {tool_label(str(event.get('toolName') or 'tool'), event.get('args'))}")
        elif kind == "tool_execution_update":
            self._stream(event, event.get("partialResult"))
        elif kind == "tool_execution_end":
            self._finish_tool(event)
        elif kind == "message_end":
            self._message_end(event.get("message") or {})

    def _stream(self, event: dict, payload: Any) -> None:
        call_id = str(event.get("toolCallId") or "")
        text = content_text(payload)
        prev = self._partial.get(call_id, "")
        delta = text[len(prev):] if text.startswith(prev) else text
        self._partial[call_id] = text
        if delta:
            sys.stdout.write(delta)
            sys.stdout.flush()
            self._need_nl = not delta.endswith("\n")

    def _finish_tool(self, event: dict) -> None:
        call_id = str(event.get("toolCallId") or "")
        if call_id not in self._partial:
            self._write(f"▸ {tool_label(str(event.get('toolName') or 'tool'), event.get('args'))}")
        if not self._partial.get(call_id):
            text = content_text(event.get("result"))
            if text:
                self._write(text, end="" if text.endswith("\n") else "\n")
        elif self._need_nl:
            sys.stdout.write("\n")
            sys.stdout.flush()
        self._need_nl = False
        if event.get("isError"):
            self._write("✗ tool error")

    def _message_end(self, message: dict) -> None:
        if message.get("role") != "assistant":
            return
        usage = message.get("usage")
        if isinstance(usage, dict):
            self.usages.append(usage)
        self.model = message.get("model") or self.model
        self.provider = message.get("provider") or self.provider
        if message.get("stopReason") in {"error", "aborted"}:
            self.failed = True
            err = message.get("errorMessage") or message.get("stopReason")
            print(err, file=sys.stderr)
        texts = [
            block.get("text")
            for block in message.get("content") or []
            if isinstance(block, dict) and block.get("type") == "text" and block.get("text")
        ]
        if texts:
            self._write("\n".join(str(t) for t in texts))

    def usage_line(self, seconds: int) -> str | None:
        if not self.usages and not self.model:
            return None
        total = {
            "input": 0.0,
            "output": 0.0,
            "reasoning": 0.0,
            "cacheRead": 0.0,
            "cacheWrite": 0.0,
            "totalTokens": 0.0,
            "cost": 0.0,
        }
        for usage in self.usages:
            total["input"] += n(usage, "input")
            total["output"] += n(usage, "output")
            total["reasoning"] += n(usage, "reasoning")
            total["cacheRead"] += n(usage, "cacheRead")
            total["cacheWrite"] += n(usage, "cacheWrite")
            total["totalTokens"] += n(usage, "totalTokens")
            total["cost"] += n(usage, "cost", "total")
        model = self.model or "?"
        provider = self.provider or "?"
        return (
            f"{model} • {provider} • {seconds}s • "
            f"{int(total['totalTokens'])} tokens "
            f"({int(total['input'])}i+{int(total['output'])}o+{int(total['reasoning'])}r, "
            f"cache {int(total['cacheRead'])}r/{int(total['cacheWrite'])}w) • "
            f"${total['cost']}"
        )


def iter_events(stream) -> Any:
    for raw in stream:
        line = raw.strip()
        if not line:
            continue
        try:
            yield json.loads(line)
        except json.JSONDecodeError:
            print(line, flush=True)


def run(argv: list[str]) -> int:
    tracer = Tracer()
    started = time.time()
    proc = None
    if argv:
        proc = subprocess.Popen(
            ["pi", "--mode", "json", *argv],
            stdout=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        assert proc.stdout is not None
        stream = proc.stdout
    else:
        stream = sys.stdin

    for event in iter_events(stream):
        if isinstance(event, dict):
            tracer.handle(event)

    code = proc.wait() if proc is not None else 0
    line = tracer.usage_line(max(0, int(time.time() - started)))
    if line:
        print(line, flush=True)
    if tracer.failed and code == 0:
        return 1
    return code


if __name__ == "__main__":
    sys.exit(run(sys.argv[1:]))
