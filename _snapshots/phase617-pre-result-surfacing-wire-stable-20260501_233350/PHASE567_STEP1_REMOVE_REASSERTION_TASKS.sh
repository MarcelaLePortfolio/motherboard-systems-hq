#!/bin/bash
set -e

echo "Removing reassertion loop from Recent Tasks wire..."

python3 - << 'PY'
from pathlib import Path
import re

path = Path("public/js/phase565_recent_tasks_wire.js")
text = path.read_text()

# Remove setInterval reassertion block
text = re.sub(
    r'let runs = 0;.*?clearInterval\(timer\);\s*\},\s*500\);\s*',
    '',
    text,
    flags=re.S
)

# Replace start function with single call
text = text.replace(
    "function startRecentTasksWire() {\n    refreshRecentTasks();\n    ",
    "function startRecentTasksWire() {\n    refreshRecentTasks();\n"
)

path.write_text(text)
print("Recent Tasks reassertion removed")
PY

node --check public/js/phase565_recent_tasks_wire.js
docker compose up -d --build dashboard

git add public/js/phase565_recent_tasks_wire.js
git commit -m "Phase 567: remove reassertion loop from Recent Tasks wire"
git push
