#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()
original = text

helper = """
const __phase64TaskEventSeen = new Set();
function __phase64TaskEventDedupKey(payload) {
  const event = payload?.event ?? null;
  if (event !== "task.event") return null;
  return (
    payload?.id ??
    payload?.data?.id ??
    payload?.data?.eventId ??
    payload?.data?.meta?.id ??
    null
  );
}
function __phase64ShouldWriteTaskEvent(payload) {
  const key = __phase64TaskEventDedupKey(payload);
  if (!key) return true;
  if (__phase64TaskEventSeen.has(key)) return false;
  __phase64TaskEventSeen.add(key);
  if (__phase64TaskEventSeen.size > 5000) {
    const first = __phase64TaskEventSeen.values().next();
    if (!first.done) __phase64TaskEventSeen.delete(first.value);
  }
  return true;
}

"""

def replace_function(src: str, name: str, replacement: str) -> str:
    marker = f"function {name}"
    start = src.find(marker)
    if start == -1:
        raise SystemExit(f"could not find {name} in {path}")
    brace_start = src.find("{", start)
    if brace_start == -1:
        raise SystemExit(f"could not find opening brace for {name}")
    depth = 0
    end = None
    for i in range(brace_start, len(src)):
        ch = src[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end is None:
        raise SystemExit(f"could not find closing brace for {name}")
    return src[:start] + replacement + src[end:]

if "__phase64ShouldWriteTaskEvent" not in text:
    insert_after = text.find("function _sseWrite")
    if insert_after == -1:
        raise SystemExit("could not find function _sseWrite for helper insertion")
    text = text[:insert_after] + helper + text[insert_after:]

replacement = """function _sseWrite(res, payload = {}) {
  if (!res || res.writableEnded) return;
  if (!__phase64ShouldWriteTaskEvent(payload)) return;

  const id = payload?.id ?? null;
  const event = payload?.event ?? null;
  const rawData = payload?.data ?? {};

  if (id != null) {
    res.write(`id: ${id}\\n`);
  }

  if (event) {
    res.write(`event: ${event}\\n`);
  }

  const body =
    typeof rawData === "string"
      ? rawData
      : JSON.stringify(rawData);

  for (const line of String(body).split("\\n")) {
    res.write(`data: ${line}\\n`);
  }

  res.write("\\n");
}
"""

text = replace_function(text, "_sseWrite", replacement)

if text == original:
    raise SystemExit("no changes applied to server/routes/task-events-sse.mjs")

path.write_text(text)
print("patched server/routes/task-events-sse.mjs by deduping task.event writes inside _sseWrite")
PY
