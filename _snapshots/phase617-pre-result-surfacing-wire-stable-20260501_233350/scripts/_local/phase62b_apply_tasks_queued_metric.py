#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

TARGET = Path("server.mjs")

if not TARGET.exists():
    print("ERROR: server.mjs not found", file=sys.stderr)
    sys.exit(1)

original = TARGET.read_text()
text = original

if "queuedTasks" in text:
    print("queuedTasks already present; no change made.")
    sys.exit(0)

patched = False

# Strategy A:
# Insert queuedTasks query immediately after runningTasks query assignment.
m = re.search(
    r"(?P<indent>^[ \t]*)const\s+runningTasks\s*=\s*(?P<body>.*?where\s+status\s*=\s*['\"]running['\"].*?;\n)",
    text,
    flags=re.MULTILINE | re.DOTALL,
)
if m:
    indent = m.group("indent")
    body = m.group("body")
    queued_block = re.sub(r"\brunningTasks\b", "queuedTasks", body, count=1)
    queued_block = re.sub(r"['\"]running['\"]", "'queued'", queued_block, count=1)
    insert_at = m.end()
    text = text[:insert_at] + f"{indent}const {queued_block}" + text[insert_at:]
    patched = True

# Strategy B:
# If metrics response object exists, expose queuedTasks next to runningTasks.
if patched:
    text, n = re.subn(
        r"(runningTasks\s*,\s*\n)([ \t]*completedTasks\s*,)",
        r"\1\2".replace("\1\2", "runningTasks,\n      queuedTasks,\n      completedTasks,"),
        text,
        count=1,
    )
    if n == 0:
        text, n = re.subn(
            r"(runningTasks\s*:.*?,\s*\n)([ \t]*completedTasks\s*:)",
            r"runningTasks,\n      queuedTasks,\n      completedTasks:",
            text,
            count=1,
        )
    if n == 0:
        text, n = re.subn(
            r"(runningTasks\s*:\s*[^,\n]+,\s*\n)([ \t]*completedTasks\s*:)",
            r"\1      queuedTasks,\n\2",
            text,
            count=1,
        )
    if n == 0:
        text, n = re.subn(
            r"(runningTasks\s*:\s*[^,\n]+,\s*)(completedTasks\s*:)",
            r"\1queuedTasks,\n      \2",
            text,
            count=1,
        )
    if n == 0:
        print("ERROR: running/completed metrics response shape not found after query insertion", file=sys.stderr)
        sys.exit(1)

# Strategy C:
# If there is a frontend metrics descriptor block in server.mjs, add queued entry.
if patched and "Tasks Queued" not in text:
    metric_block_patterns = [
        (
            r"(\{\s*id:\s*['\"]metric-running['\"].*?label:\s*['\"]Tasks Running['\"].*?\}\s*,\s*\n)",
            "{ id: 'metric-queued', label: 'Tasks Queued', value: queuedTasks },\n",
        ),
        (
            r"(\{\s*key:\s*['\"]runningTasks['\"].*?label:\s*['\"]Tasks Running['\"].*?\}\s*,\s*\n)",
            "{ key: 'queuedTasks', label: 'Tasks Queued', value: queuedTasks },\n",
        ),
    ]
    for pattern, addition in metric_block_patterns:
        text, n = re.subn(pattern, r"\1" + addition, text, count=1, flags=re.DOTALL)
        if n:
            break

if text == original:
    print("ERROR: no safe patch was applied", file=sys.stderr)
    sys.exit(1)

TARGET.write_text(text)
print("Patched server.mjs for queuedTasks metric.")
