#!/bin/bash
set -e

TARGET_FILE="public/index.html"

python3 - "$TARGET_FILE" << 'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

tasks = '  <script defer src="js/phase565_recent_tasks_wire.js"></script>\n'
logs = '  <script defer src="js/phase565_recent_logs_wire.js"></script>\n'

text = text.replace(tasks, "")
text = text.replace(logs, "")

anchor = '  <script defer src="/js/phase487_humanize_task_ids.js"></script>'
insert = anchor + '\n' + tasks + logs

if anchor not in text:
    raise SystemExit("Expected final script anchor not found")

text = text.replace(anchor, insert, 1)
path.write_text(text)
print("Moved Phase 565 telemetry wires to final load position")
PY

node --check public/js/phase565_recent_tasks_wire.js
node --check public/js/phase565_recent_logs_wire.js

docker compose up -d --build dashboard

git add public/index.html public/js/phase565_recent_tasks_wire.js public/js/phase565_recent_logs_wire.js
git commit -m "Phase 565: move telemetry wires to final dashboard load order"
git push
