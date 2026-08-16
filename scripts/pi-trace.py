#!/usr/bin/env python3
"""Run `pi --mode json` and print a tool/text transcript plus usage.

With no args and stdin piped, formats a JSONL event stream instead.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from typing import Any


def _use_color() -> bool:
    if os.environ.get("NO_COLOR"):
        return False
    if os.environ.get("FORCE_COLOR"):
        return True
    return sys.stdout.isatty()


COLOR = _use_color()

# 256-color, close to Pi's dark theme.
C = {
    "reset": "\033[0m",
    "bold": "\033[1m",
    "dim": "\033[2m",
    "text": "\033[38;5;252m",
    "muted": "\033[38;5;245m",
    "dimmer": "\033[38;5;240m",
    "accent": "\033[38;5;80m",
    "cyan": "\033[38;5;81m",
    "blue": "\033[38;5;75m",
    "green": "\033[38;5;143m",
    "red": "\033[38;5;167m",
    "yellow": "\033[38;5;221m",
    "purple": "\033[38;5;183m",
}


def paint(text: str, *styles: str) -> str:
    if not COLOR or not text:
        return text
    return "".join(C[s] for s in styles) + text + C["reset"]


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


def tool_detail(name: str, args: Any) -> str:
    if not isinstance(args, dict):
        return ""
    if name == "bash":
        return str(args.get("command") or "")
    if name in {"read", "edit", "write"}:
        return str(args.get("path") or "")
    if name == "grep":
        parts = [str(args.get("pattern") or "")]
        where = args.get("path") or args.get("glob")
        if where:
            parts.append(str(where))
        return "  ".join(p for p in parts if p)
    if name in {"find", "ls"}:
        return str(args.get("path") or args.get("pattern") or "")
    if args:
        return json.dumps(args, ensure_ascii=False)
    return ""


def n(usage: dict, *keys: str) -> float:
    cur: Any = usage
    for key in keys:
        if not isinstance(cur, dict):
            return 0
        cur = cur.get(key)
    if isinstance(cur, (int, float)):
        return cur
    return 0


_STATUS = re.compile(r"^([ MADRCU?!]{1,2})\s+(.*)$")
_INLINE_CODE = re.compile(r"`([^`]+)`")
_BOLD = re.compile(r"\*\*([^*]+)\*\*")


def color_output_line(line: str) -> str:
    if not COLOR:
        return line
    if line.startswith("??"):
        return paint(line, "blue")
    match = _STATUS.match(line)
    if match and any(ch not in " " for ch in match.group(1)):
        code = match.group(1)
        if "D" in code:
            return paint(line, "red")
        if "A" in code or "C" in code:
            return paint(line, "green")
        if "M" in code or "R" in code or "U" in code:
            return paint(line, "yellow")
    if line.startswith("+") and not line.startswith("+++"):
        return paint(line, "green")
    if line.startswith("-") and not line.startswith("---"):
        return paint(line, "red")
    if line.startswith("@@"):
        return paint(line, "cyan")
    if line.startswith(("diff ", "index ", "--- ", "+++ ")):
        return paint(line, "muted")
    if line.startswith("ok "):
        return paint("ok", "green", "bold") + " " + paint(line[3:], "muted")
    return paint(line, "muted")


def color_assistant(text: str) -> str:
    if not COLOR:
        return text

    def code(match: re.Match[str]) -> str:
        return paint(match.group(1), "accent")

    def bold(match: re.Match[str]) -> str:
        return paint(match.group(1), "bold", "text")

    styled = _INLINE_CODE.sub(code, text)
    return _BOLD.sub(bold, styled)


class LineBuffer:
    def __init__(self, emit) -> None:
        self._buf = ""
        self._emit = emit

    def feed(self, delta: str) -> None:
        self._buf += delta
        while "\n" in self._buf:
            line, self._buf = self._buf.split("\n", 1)
            self._emit(line)

    def flush(self) -> None:
        if self._buf:
            self._emit(self._buf)
            self._buf = ""


class Tracer:
    def __init__(self) -> None:
        self.usages: list[dict] = []
        self.model: str | None = None
        self.provider: str | None = None
        self.failed = False
        self.tool_count = 0
        self.error_count = 0
        self._partial: dict[str, str] = {}
        self._buffers: dict[str, LineBuffer] = {}
        self._started: dict[str, float] = {}
        self._last: str | None = None

    def _gap(self, kind: str) -> None:
        if self._last:
            sys.stdout.write("\n")
        self._last = kind

    def _out(self, text: str = "", end: str = "\n") -> None:
        sys.stdout.write(text)
        sys.stdout.write(end)
        sys.stdout.flush()

    def handle(self, event: dict) -> None:
        kind = event.get("type")
        if kind == "tool_execution_start":
            self._tool_start(event)
        elif kind == "tool_execution_update":
            self._stream(event, event.get("partialResult"))
        elif kind == "tool_execution_end":
            self._finish_tool(event)
        elif kind == "message_end":
            self._message_end(event.get("message") or {})

    def _tool_start(self, event: dict) -> None:
        call_id = str(event.get("toolCallId") or "")
        name = str(event.get("toolName") or "tool")
        detail = tool_detail(name, event.get("args"))
        self._partial[call_id] = ""
        self._started[call_id] = time.time()
        self.tool_count += 1
        self._gap("tool")

        bullet = paint("●", "cyan", "bold")
        label = paint(name, "cyan", "bold")
        if detail and "\n" not in detail and len(detail) < 100:
            self._out(f"{bullet} {label}  {paint(detail, 'text')}")
        else:
            self._out(f"{bullet} {label}")
            if detail:
                for line in detail.splitlines() or [detail]:
                    self._out(f"  {paint(line, 'text')}")
        self._buffers[call_id] = LineBuffer(self._emit_output)

    def _emit_output(self, line: str) -> None:
        gutter = paint("│", "dimmer")
        self._out(f"{gutter} {color_output_line(line)}")

    def _stream(self, event: dict, payload: Any) -> None:
        call_id = str(event.get("toolCallId") or "")
        text = content_text(payload)
        prev = self._partial.get(call_id, "")
        delta = text[len(prev):] if text.startswith(prev) else text
        self._partial[call_id] = text
        buf = self._buffers.get(call_id)
        if buf and delta:
            buf.feed(delta)

    def _finish_tool(self, event: dict) -> None:
        call_id = str(event.get("toolCallId") or "")
        name = str(event.get("toolName") or "tool")
        if call_id not in self._partial:
            self._tool_start(event)
        buf = self._buffers.get(call_id)
        if not self._partial.get(call_id):
            text = content_text(event.get("result"))
            if buf and text:
                buf.feed(text if text.endswith("\n") else text + "\n")
        if buf:
            buf.flush()
        elapsed_s = time.time() - self._started[call_id] if call_id in self._started else 0.0
        slow = paint(f"  {elapsed_s:.1f}s", "dimmer") if elapsed_s >= 1.0 else ""
        if event.get("isError"):
            self.error_count += 1
            self._out(f"{paint('✗', 'red', 'bold')} {paint(name + ' failed', 'red')}{slow}")

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
            print(paint(str(err), "red"), file=sys.stderr)
        texts = [
            block.get("text")
            for block in message.get("content") or []
            if isinstance(block, dict) and block.get("type") == "text" and block.get("text")
        ]
        if texts:
            self._gap("assistant")
            self._out(color_assistant("\n".join(str(t) for t in texts)))

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

        model = paint(self.model or "?", "bold", "text")
        provider = paint(self.provider or "?", "muted")
        dur = paint(f"{seconds}s", "yellow")
        tokens = paint(f"{int(total['totalTokens'])} tokens", "text")
        breakdown = paint(
            f"({int(total['input'])}i+{int(total['output'])}o+{int(total['reasoning'])}r, "
            f"cache {int(total['cacheRead'])}r/{int(total['cacheWrite'])}w)",
            "muted",
        )
        cost = paint(f"${total['cost']}", "green", "bold")
        extras = []
        if self.tool_count:
            extras.append(paint(f"{self.tool_count} tools", "muted"))
        if self.error_count:
            extras.append(paint(f"{self.error_count} failed", "red"))
        extra = ("  " + "  ".join(extras)) if extras else ""
        rule = paint("─" * 48, "dimmer")
        stats = (
            f"{model} {paint('•', 'dimmer')} {provider} {paint('•', 'dimmer')} "
            f"{dur} {paint('•', 'dimmer')} {tokens} {breakdown} {paint('•', 'dimmer')} {cost}"
        )
        return f"{rule}\n{stats}{extra}"


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
        if tracer._last:
            print()
        print(line, flush=True)
    if tracer.failed and code == 0:
        return 1
    return code


if __name__ == "__main__":
    sys.exit(run(sys.argv[1:]))
