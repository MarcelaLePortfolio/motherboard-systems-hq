#!/bin/bash
set -e

TARGET_FILE="$(grep -RIl 'phase61_recent_history_wire.js' public . | head -n 1)"

if [ -z "$TARGET_FILE" ]; then
  echo "Could not find dashboard HTML file containing phase61_recent_history_wire.js"
  exit 1
fi

echo "Updating $TARGET_FILE"

python3 - "$TARGET_FILE" << 'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

needle = '  <script defer src="js/phase61_recent_history_wire.js"></script>'
insert = needle + '\n  <script defer src="js/phase565_recent_tasks_wire.js"></script>'

if 'phase565_recent_tasks_wire.js' in text:
    print("phase565_recent_tasks_wire.js already loaded")
else:
    if needle not in text:
        raise SystemExit("Expected script anchor not found")
    text = text.replace(needle, insert, 1)
    path.write_text(text)
    print("Inserted phase565_recent_tasks_wire.js")
PY

node --check public/js/phase565_recent_tasks_wire.js

git add "$TARGET_FILE" public/js/phase565_recent_tasks_wire.js
git commit -m "Phase 565: load Recent Tasks read-only UI wire"
git push
