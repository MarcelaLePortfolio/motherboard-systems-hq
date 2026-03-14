#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()
original = text

helper = r'''
const __phase64TaskEventsSeenByRes = new WeakMap();

function __phase64TaskEventKey(payload = {}) {
  if ((payload?.event ?? null) !== "task.event") return null;

  const data = payload?.data ?? {};
  const directId = payload?.id ?? data?.id ?? null;
  if (directId != null) return `id:${directId}`;

  const taskId = data?.taskId ?? data?.task_id ?? data?.meta?.task_id ?? null;
  const runId = data?.runId ?? data?.run_id ?? data?.meta?.run_id ?? null;
  const eventType = data?.type ?? data?.kind ?? null;
  const ts = data?.ts ?? data?.createdAt ?? data?.created_at ?? null;

  return `composite:${taskId ?? "na"}:${runId ?? "na"}:${eventType ?? "na"}:${ts ?? "na"}`;
}

function __phase64ShouldWriteTaskEvent(res, payload = {}) {
  const key = __phase64TaskEventKey(payload);
  if (!key) return true;

  let seen = __phase64TaskEventsSeenByRes.get(res);
  if (!seen) {
    seen = new Set();
    __phase64TaskEventsSeenByRes.set(res, seen);
  }

  if (seen.has(key)) return false;

  seen.add(key);

  if (seen.size > 10000) {
    const keep = key;
    seen.clear();
    seen.add(keep);
  }

  return true;
}
'''.strip("\n")

def find_function_span(src: str, signature: str):
    start = src.find(signature)
    if start == -1:
        raise SystemExit(f"could not find function signature: {signature}")
    brace_start = src.find("{", start)
    if brace_start == -1:
        raise SystemExit(f"could not find opening brace for: {signature}")
    depth = 0
    i = brace_start
    in_single = False
    in_double = False
    in_template = False
    escape = False
    while i < len(src):
        ch = src[i]
        if escape:
            escape = False
        elif ch == "\\":
            escape = True
        elif in_single:
            if ch == "'":
                in_single = False
        elif in_double:
            if ch == '"':
                in_double = False
        elif in_template:
            if ch == "`":
                in_template = False
        else:
            if ch == "'":
                in_single = True
            elif ch == '"':
                in_double = True
            elif ch == "`":
                in_template = True
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    return start, i + 1
        i += 1
    raise SystemExit(f"could not find closing brace for: {signature}")

if "__phase64ShouldWriteTaskEvent" not in text:
    sig = "function _sseWrite("
    start, _ = find_function_span(text, sig)
    text = text[:start] + helper + "\n\n" + text[start:]

replacement = '''
function _sseWrite(res, payload = {}) {
  if (!res || res.writableEnded) return;
  if (!__phase64ShouldWriteTaskEvent(res, payload)) return;

  if (payload.id != null) {
    res.write(`id: ${payload.id}\\n`);
  }

  if (payload.event) {
    res.write(`event: ${payload.event}\\n`);
  }

  const body =
    typeof payload.data === "string"
      ? payload.data
      : JSON.stringify(payload.data ?? {});

  for (const line of String(body).split("\\n")) {
    res.write(`data: ${line}\\n`);
  }

  res.write("\\n");
}
'''.strip("\n")

start, end = find_function_span(text, "function _sseWrite(")
text = text[:start] + replacement + text[end:]

if text == original:
    raise SystemExit("no changes applied to server/routes/task-events-sse.mjs")

path.write_text(text)
print("patched server/routes/task-events-sse.mjs with safe per-connection task.event dedupe")
PY
