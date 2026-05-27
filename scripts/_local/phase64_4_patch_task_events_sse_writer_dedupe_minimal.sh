#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()
original = text

needle = "function _sseWrite(res, payload = {}) {"
start = text.find(needle)
if start == -1:
    raise SystemExit("could not find function _sseWrite(res, payload = {}) in server/routes/task-events-sse.mjs")

brace_start = text.find("{", start)
if brace_start == -1:
    raise SystemExit("could not find opening brace for _sseWrite")

depth = 0
end = None
for i in range(brace_start, len(text)):
    ch = text[i]
    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            end = i + 1
            break

if end is None:
    raise SystemExit("could not locate end of _sseWrite function")

replacement = """function _sseWrite(res, payload = {}) {
  if (!res || res.writableEnded) return;

  if (payload?.event === "task.event") {
    if (!res.__phase64TaskEventSeen) {
      res.__phase64TaskEventSeen = new Set();
    }

    const dedupeKey =
      payload?.id ??
      payload?.data?.id ??
      [
        payload?.data?.type ?? "task.event",
        payload?.data?.taskId ?? payload?.data?.task_id ?? "no-task",
        payload?.data?.runId ?? payload?.data?.run_id ?? "no-run",
        payload?.data?.ts ?? "no-ts",
      ].join(":");

    if (res.__phase64TaskEventSeen.has(dedupeKey)) {
      return;
    }

    res.__phase64TaskEventSeen.add(dedupeKey);

    if (res.__phase64TaskEventSeen.size > 5000) {
      const seen = Array.from(res.__phase64TaskEventSeen);
      res.__phase64TaskEventSeen = new Set(seen.slice(-2000));
    }
  }

  if (payload?.id != null) {
    res.write(`id: ${payload.id}\\n`);
  }

  if (payload?.event) {
    res.write(`event: ${payload.event}\\n`);
  }

  const body =
    typeof payload?.data === "string"
      ? payload.data
      : JSON.stringify(payload?.data ?? {});

  for (const line of String(body).split("\\n")) {
    res.write(`data: ${line}\\n`);
  }

  res.write("\\n");
}"""

text = text[:start] + replacement + text[end:]

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched server/routes/task-events-sse.mjs")
PY
