#!/bin/bash
set -e

echo "Removing remaining setInterval residue from Recent Logs wire..."

python3 - << 'PY'
from pathlib import Path
import re

path = Path("public/js/phase565_recent_logs_wire.js")
text = path.read_text()

text = re.sub(
    r'\n\s*let runs = 0;\s*const timer = window\.setInterval\(function \(\) \{.*?window\.clearInterval\(timer\);\s*\}\s*\}, 500\);\s*',
    '\n',
    text,
    flags=re.S
)

path.write_text(text)
print("Recent Logs setInterval residue removed")
PY

node --check public/js/phase565_recent_logs_wire.js
./PHASE567_STEP3_VERIFY_NO_REASSERTION.sh

git add public/js/phase565_recent_logs_wire.js
git commit -m "Phase 567: remove remaining Recent Logs reassertion residue"
git push
