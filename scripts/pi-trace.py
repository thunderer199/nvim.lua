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
import threading
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


def fmt_int(value: float) -> str:
    return f"{int(round(value)):,}"


def fmt_usd(value: float) -> str:
    if value == 0:
        return "$0"
    return "$" + f"{value:.6f}".rstrip("0").rstrip(".")


def fmt_duration(seconds: int) -> str:
    if seconds < 60:
        return f"{seconds}s"
    minutes, sec = divmod(seconds, 60)
    if minutes < 60:
        return f"{minutes}m {sec:02d}s"
    hours, minutes = divmod(minutes, 60)
    return f"{hours}h {minutes:02d}m {sec:02d}s"


def align_rows(rows: list[tuple[str, str]]) -> list[str]:
    width = max((len(value) for _, value in rows), default=0)
    return [f"{value.rjust(width)}  {label}" for label, value in rows]


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
    def __init__(self, on_output=None) -> None:
        self._on_output = on_output
        self._announced = False
        self.usages: list[dict] = []
        self.model: str | None = None
        self.provider: str | None = None
        self.failed = False
        self.tool_count = 0
        self.error_count = 0
        self._partial: dict[str, str] = {}
        self._details: dict[str, str] = {}
        self._buffers: dict[str, LineBuffer] = {}
        self._started: dict[str, float] = {}
        self._last: str | None = None

    def _gap(self, kind: str) -> None:
        if self._last:
            sys.stdout.write("\n")
        self._last = kind

    def _announce(self) -> None:
        """Clear the startup hint just before the first transcript output."""
        if not self._announced:
            self._announced = True
            if self._on_output:
                self._on_output()

    def _out(self, text: str = "", end: str = "\n") -> None:
        self._announce()
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
        self._details[call_id] = detail
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
            detail = self._details.get(call_id, "")
            if detail:
                shown = detail if len(detail) <= 200 else detail[:200] + paint("…", "dimmer")
                first, _, rest = shown.partition("\n")
                self._out(f"  {paint('command:', 'red')} {paint(first, 'text')}")
                for line in rest.splitlines():
                    self._out(f"    {paint(line, 'text')}")
            error_text = content_text(event.get("result")).strip()
            if error_text:
                lines = error_text.splitlines()
                keep = lines[:6]
                if len(lines) > 6:
                    keep.append(f"… (+{len(lines) - 6} more lines)")
                self._out(f"  {paint('error:', 'red', 'bold')}")
                for line in keep:
                    self._out(f"    {paint(line, 'red')}")

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
            self._announce()
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

    def usage_block(self, seconds: int) -> str | None:
        if not self.usages and not self.model:
            return None
        tokens = {
            "input": 0.0,
            "output": 0.0,
            "reasoning": 0.0,
            "cacheRead": 0.0,
            "cacheWrite": 0.0,
            "total": 0.0,
        }
        cost = {
            "input": 0.0,
            "output": 0.0,
            "cacheRead": 0.0,
            "cacheWrite": 0.0,
            "total": 0.0,
        }
        for usage in self.usages:
            tokens["input"] += n(usage, "input")
            tokens["output"] += n(usage, "output")
            tokens["reasoning"] += n(usage, "reasoning")
            tokens["cacheRead"] += n(usage, "cacheRead")
            tokens["cacheWrite"] += n(usage, "cacheWrite")
            tokens["total"] += n(usage, "totalTokens")
            cost["input"] += n(usage, "cost", "input")
            cost["output"] += n(usage, "cost", "output")
            cost["cacheRead"] += n(usage, "cost", "cacheRead")
            cost["cacheWrite"] += n(usage, "cost", "cacheWrite")
            cost["total"] += n(usage, "cost", "total")

        billed = tokens["input"] + tokens["cacheRead"]
        hit = (tokens["cacheRead"] / billed * 100) if billed else 0.0

        meta = [
            paint(self.model or "?", "bold", "text"),
            paint(self.provider or "?", "muted"),
            paint(fmt_duration(seconds), "yellow"),
        ]
        if self.tool_count:
            noun = "tool" if self.tool_count == 1 else "tools"
            meta.append(paint(f"{self.tool_count} {noun}", "muted"))
        if self.error_count:
            noun = "failed" if self.error_count == 1 else "failed"
            meta.append(paint(f"{self.error_count} {noun}", "red"))

        token_rows = align_rows([
            ("total", fmt_int(tokens["total"])),
            ("input", fmt_int(tokens["input"])),
            ("output", fmt_int(tokens["output"])),
            ("reasoning", fmt_int(tokens["reasoning"])),
            ("cache read", fmt_int(tokens["cacheRead"])),
            ("cache write", fmt_int(tokens["cacheWrite"])),
        ])
        cost_rows = [("total", fmt_usd(cost["total"]))]
        for label, key in (
            ("input", "input"),
            ("output", "output"),
            ("cache read", "cacheRead"),
            ("cache write", "cacheWrite"),
        ):
            if cost[key] >= 1e-6:
                cost_rows.append((label, fmt_usd(cost[key])))
        cost_lines = align_rows(cost_rows)

        lines = [
            paint("─" * 32, "dimmer"),
            f"  {paint(' • ', 'dimmer').join(meta)}",
            "",
            f"  {paint('tokens', 'cyan', 'bold')}"
            + (paint(f"   cache hit {hit:.0f}%", "accent") if billed else ""),
        ]
        for i, row in enumerate(token_rows):
            style = ("bold", "text") if i == 0 else ("muted",)
            lines.append(f"    {paint(row, *style)}")
        lines.append("")
        lines.append(f"  {paint('cost', 'green', 'bold')}")
        for i, row in enumerate(cost_lines):
            style = ("bold", "green") if i == 0 else ("muted",)
            lines.append(f"    {paint(row, *style)}")
        return "\n".join(lines)


HANDLED_EVENT_KINDS = {
    "tool_execution_start",
    "tool_execution_update",
    "tool_execution_end",
    "message_end",
}


class PerfTracer:
    """Times the JSONL event stream to reveal where wall-clock time goes.

    Intervals between events are attributed to tool exec while at least one
    tool is running, otherwise to model/loop (pi itself + streaming). Gaps
    outside tool exec that exceed STALL_THRESHOLD are kept as stalls.
    """

    STALL_THRESHOLD = 0.5

    def __init__(self, enabled: bool = False) -> None:
        self.enabled = enabled
        self._t0 = time.monotonic()
        self._prev: float | None = None
        self._prev_kind: str | None = None
        self._open_tools = 0
        self.tool_secs = 0.0
        self.model_secs = 0.0
        self.total_secs = 0.0
        self.stalls: list[tuple[float, str]] = []
        self.first_event: float | None = None
        self.type_counts: dict[str, int] = {}

    def record(self, kind: str, label: str = "") -> None:
        now = time.monotonic() - self._t0
        delta = now - self._prev if self._prev is not None else 0.0
        self.type_counts[kind] = self.type_counts.get(kind, 0) + 1
        if self.first_event is None:
            self.first_event = now
        if self._prev is not None:
            if self._open_tools > 0:
                self.tool_secs += delta
            else:
                self.model_secs += delta
                if delta >= self.STALL_THRESHOLD and self._prev_kind:
                    self.stalls.append((delta, f"{self._prev_kind} \u2192 {kind}"))
        if kind == "tool_execution_start":
            self._open_tools += 1
        elif kind == "tool_execution_end":
            self._open_tools = max(0, self._open_tools - 1)
        if self.enabled:
            suffix = f"  {label}" if label else ""
            unhandled = "" if kind in HANDLED_EVENT_KINDS else "  (unhandled)"
            sys.stderr.write(f"[+{now:7.2f}s \u0394{delta:5.2f}s] {kind}{suffix}{unhandled}\n")
            sys.stderr.flush()
        self._prev = now
        self._prev_kind = kind

    def finish(self) -> None:
        self.total_secs = time.monotonic() - self._t0

    def summary_lines(self) -> list[str]:
        rows = [
            ("wall", f"{self.total_secs:.1f}s"),
            ("startup", f"{self.first_event:.1f}s" if self.first_event is not None else "-"),
            ("model/loop", f"{self.model_secs:.1f}s"),
            ("tool exec", f"{self.tool_secs:.1f}s"),
        ]
        lines = [f"  {paint('timing', 'cyan', 'bold')}"]
        for i, row in enumerate(align_rows(rows)):
            style = ("bold", "text") if i == 0 else ("muted",)
            lines.append(f"    {paint(row, *style)}")
        if self.stalls:
            lines.append(f"  {paint('top stalls', 'green', 'bold')}")
            for gap, boundary in sorted(self.stalls, key=lambda s: -s[0])[:3]:
                lines.append(f"    {paint(f'{gap:.1f}s', 'yellow')}  {paint(boundary, 'dimmer')}")
        if self.enabled and self.type_counts:
            lines.append(f"  {paint('events', 'purple', 'bold')}")
            ordered = sorted(self.type_counts.items(), key=lambda kv: (-kv[1], kv[0]))
            for kind, count in ordered:
                mark = "" if kind in HANDLED_EVENT_KINDS else paint("  unhandled", "red")
                lines.append(f"    {paint(f'{count:>4}x', 'muted')}  {paint(kind, 'text')}{mark}")
        return lines


class StartupHint:
    """'Waiting for pi' line shown until the first event arrives.

    The gap before pi emits anything (startup, auth, context load, first
    token) looks like a hang; this makes the wait visible. Call finish()
    exactly once; safe if no events ever arrive.

    Lives on stderr so it never pollutes the transcript piped into stdout.
    On a TTY stderr it ticks in place; otherwise it is a single line.
    """

    def __init__(self, suffix: str = "") -> None:
        self._done = threading.Event()
        self._t0 = time.monotonic()
        self._suffix = suffix
        self._label = "starting pi"
        self._tty = sys.stderr.isatty()
        self._painted_label: str | None = None
        self._paint(0)
        self._thread = threading.Thread(target=self._tick, daemon=True)
        self._thread.start()

    def phase(self, label: str) -> None:
        self._label = label
        self._paint(int(time.monotonic() - self._t0))

    def _text(self, secs: int) -> str:
        return f"{self._label}\u2026 {secs}s" + (f" \u00b7 {self._suffix}" if self._suffix else "")

    def _paint(self, secs: int) -> None:
        if not self._tty:
            # Non-TTY: only line per phase, no per-second spam.
            if self._painted_label == self._label:
                return
            self._painted_label = self._label
        text = paint(self._text(secs), "muted") if self._tty else self._text(secs)
        sys.stderr.write(("\r\033[K" if self._tty else "") + text + ("\n" if not self._tty else ""))
        sys.stderr.flush()

    def _tick(self) -> None:
        while not self._done.wait(1.0):
            self._paint(int(time.monotonic() - self._t0))

    def finish(self) -> None:
        self._done.set()
        if self._tty:
            sys.stderr.write("\r\033[K")
            sys.stderr.flush()


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
    perf = PerfTracer(enabled=bool(os.environ.get("PI_TRACE_PERF")))
    started = time.time()

    # Hint first, before anything can fail; stderr keeps it out of piped
    # output. The gap before the first event (or a missing `pi`) is exactly
    # what this makes visible.
    model = argv[argv.index("--model") + 1] if "--model" in argv else ""
    hint: StartupHint | None = StartupHint(model)

    def clear_hint() -> None:
        nonlocal hint
        if hint:
            hint.finish()
            hint = None

    tracer = Tracer(on_output=clear_hint)
    proc = None
    if argv:
        try:
            proc = subprocess.Popen(
                ["pi", "--mode", "json", *argv],
                stdout=subprocess.PIPE,
                text=True,
                encoding="utf-8",
                errors="replace",
            )
        except FileNotFoundError:
            hint.finish()
            print(paint("error: `pi` not found on PATH", "red", "bold"), file=sys.stderr)
            print("when run from nvim, :! uses a limited PATH — check $PATH", file=sys.stderr)
            return 127
        assert proc.stdout is not None
        stream = proc.stdout
    else:
        stream = sys.stdin

    try:
        for event in iter_events(stream):
            if isinstance(event, dict):
                # Events flow but nothing is on screen yet: model is loading
                # context or thinking. Relabel instead of erasing the hint.
                if hint and hint._label == "starting pi":
                    hint.phase("thinking")
                perf.record(str(event.get("type") or "?"), label=str(event.get("toolName") or ""))
                tracer.handle(event)
    finally:
        clear_hint()

    code = proc.wait() if proc is not None else 0
    perf.finish()
    tail = tracer.usage_block(max(0, int(time.time() - started))) or ""
    if perf.type_counts:
        tail += ("\n\n" if tail else "") + "\n".join(perf.summary_lines())
    if tail:
        if tracer._last:
            print()
        print(tail, flush=True)
    if tracer.failed and code == 0:
        return 1
    return code


if __name__ == "__main__":
    sys.exit(run(sys.argv[1:]))
