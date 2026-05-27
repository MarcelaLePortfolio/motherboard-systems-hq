#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()

needle = '  <script src="js/phase64_agent_activity_bootstrap.js"></script>'
insert = needle + '\n  <script src="js/phase64_agent_activity_debug.js"></script>'

if 'js/phase64_agent_activity_debug.js' in text:
    print("phase64 debug script already mounted in dashboard.html")
else:
    if needle not in text:
        raise SystemExit("required phase64 bootstrap anchor not found in public/dashboard.html")
    text = text.replace(needle, insert, 1)
    path.write_text(text)
    print("mounted phase64 debug script in dashboard.html")
PY
