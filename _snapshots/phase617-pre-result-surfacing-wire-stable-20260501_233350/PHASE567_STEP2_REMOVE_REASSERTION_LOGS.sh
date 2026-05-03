#!/bin/bash
set -e

echo "Removing reassertion loop from Recent Logs wire..."

python3 - << 'PY'
from pathlib import Path
import re

path = Path("public/js/phase565_recent_logs_wire.js")
text = path.read_text()

# Remove setInterval reassertion block
text = re.sub(
    r'let runs = 0;.*?clearInterval\(timer\);\s*\},\s*500\);\s*',
    '',
    text,
    flags=re.S
)

path.write_text(text)
print("Recent Logs reassertion removed")
PY

node --check public/js/phase565_recent_logs_wire.js
docker compose up -d --build dashboard

git add public/js/phase565_recent_logs_wire.js
git commit -m "Phase 567: remove reassertion loop from Recent Logs wire"
git push
