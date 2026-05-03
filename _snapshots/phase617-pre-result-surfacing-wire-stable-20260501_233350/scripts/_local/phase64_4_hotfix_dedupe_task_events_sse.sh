#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
import re

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()
original = text

helper = """
    const __phase64SentTaskEventIds = new Set();
    function __phase64ShouldEmitTaskEvent(id) {
      if (!id) return true;
      if (__phase64SentTaskEventIds.has(id)) return false;
      __phase64SentTaskEventIds.add(id);
      if (__phase64SentTaskEventIds.size > 5000) {
        const first = __phase64SentTaskEventIds.values().next();
        if (!first.done) __phase64SentTaskEventIds.delete(first.value);
      }
      return true;
    }
"""

if "__phase64ShouldEmitTaskEvent" not in text:
    hello_pat = re.compile(
        r'(\s*_sseWrite\(res,\s*\{\s*event:\s*"hello".*?\}\s*\);\n)',
        re.DOTALL,
    )
    m = hello_pat.search(text)
    if not m:
        raise SystemExit("could not find hello SSE write in server/routes/task-events-sse.mjs")
    text = text[:m.end()] + helper + text[m.end():]

pattern = re.compile(
    r'_sseWrite\(res,\s*\{\s*event:\s*"task\.event"(?P<body>.*?)\}\s*\);',
    re.DOTALL,
)

count = 0
def repl(match):
    global count
    body = match.group("body")
    return (
        'const __phase64Evt = { event: "task.event"' + body + ' };\n'
        '          const __phase64EvtId = __phase64Evt.id ?? __phase64Evt.data?.id ?? null;\n'
        '          if (__phase64ShouldEmitTaskEvent(__phase64EvtId)) {\n'
        '            _sseWrite(res, __phase64Evt);\n'
        '          }\n'
    )

new_text, count = pattern.subn(repl, text)
text = new_text

if count == 0:
    raise SystemExit("no task.event SSE writes found to patch in server/routes/task-events-sse.mjs")

if text == original:
    raise SystemExit("no changes applied to server/routes/task-events-sse.mjs")

path.write_text(text)
print(f"patched server/routes/task-events-sse.mjs with duplicate SSE guard; replacements={count}")
PY
