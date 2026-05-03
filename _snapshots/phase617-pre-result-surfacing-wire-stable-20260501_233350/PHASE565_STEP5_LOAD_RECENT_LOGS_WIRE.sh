#!/bin/bash
set -e

TARGET_FILE="public/index.html"

python3 - "$TARGET_FILE" << 'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

needle = '  <script defer src="js/phase565_recent_tasks_wire.js"></script>'
insert = needle + '\n  <script defer src="js/phase565_recent_logs_wire.js"></script>'

if 'phase565_recent_logs_wire.js' in text:
    print("phase565_recent_logs_wire.js already loaded")
else:
    if needle not in text:
        raise SystemExit("Expected Recent Tasks script anchor not found")
    text = text.replace(needle, insert, 1)
    path.write_text(text)
    print("Inserted phase565_recent_logs_wire.js")
PY

node --check public/js/phase565_recent_logs_wire.js

git add "$TARGET_FILE" public/js/phase565_recent_logs_wire.js
git commit -m "Phase 565: load Recent Logs read-only SSE wire"
git push
