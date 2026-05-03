#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
import re

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()
original = text

match = re.search(r'function\s+_sseWrite\s*\([^)]*\)\s*\{', text)
if not match:
    raise SystemExit("could not find _sseWrite function in server/routes/task-events-sse.mjs")

start = match.start()
brace_start = text.find("{", match.start())
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

  const normalized =
    payload && typeof payload === "object" && !Array.isArray(payload)
      ? payload
      : { data: payload };

  const event = normalized?.event ?? null;
  const id = normalized?.id ?? null;
  const data = normalized?.data ?? {};

  if (event === "task.event") {
    if (!res.__phase64TaskEventSeen) {
      res.__phase64TaskEventSeen = new Set();
    }

    const dedupeKey =
      id ??
      data?.id ??
      [
        data?.type ?? "task.event",
        data?.taskId ?? data?.task_id ?? "no-task",
        data?.runId ?? data?.run_id ?? "no-run",
        data?.ts ?? "no-ts",
      ].join(":");

    if (res.__phase64TaskEventSeen.has(dedupeKey)) {
      return;
    }

    res.__phase64TaskEventSeen.add(dedupeKey);

    if (res.__phase64TaskEventSeen.size > 5000) {
      const keep = Array.from(res.__phase64TaskEventSeen).slice(-2000);
      res.__phase64TaskEventSeen = new Set(keep);
    }
  }

  if (id != null) {
    res.write(`id: ${id}\\n`);
  }

  if (event) {
    res.write(`event: ${event}\\n`);
  }

  const body =
    typeof data === "string"
      ? data
      : JSON.stringify(data);

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
