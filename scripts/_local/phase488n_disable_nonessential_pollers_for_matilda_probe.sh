#!/bin/bash
set -euo pipefail

python3 << 'PY'
from pathlib import Path

path = Path("public/index.html")
text = path.read_text()

replacements = [
    (
        '<script defer src="js/phase64_agent_activity_wire.js"></script>',
        '<!-- phase488n temporary isolation: disabled to reduce /api/runs and /api/tasks polling during Matilda probe :: <script defer src="js/phase64_agent_activity_wire.js"></script> -->'
    ),
    (
        '<script defer src="js/phase61_recent_history_wire.js"></script>',
        '<!-- phase488n temporary isolation: disabled to reduce /api/runs and /api/tasks polling during Matilda probe :: <script defer src="js/phase61_recent_history_wire.js"></script> -->'
    ),
    (
        '<script defer src="js/dashboard-graph.js"></script>',
        '<!-- phase488n temporary isolation: disabled to reduce /api/tasks polling during Matilda probe :: <script defer src="js/dashboard-graph.js"></script> -->'
    ),
    (
        '<script defer src="js/phase457_restore_task_panels.js"></script>',
        '<!-- phase488n temporary isolation: disabled during Matilda probe :: <script defer src="js/phase457_restore_task_panels.js"></script> -->'
    ),
    (
        '<script defer src="js/operatorGuidance.sse.js"></script>',
        '<!-- phase488n temporary isolation: disabled during Matilda probe :: <script defer src="js/operatorGuidance.sse.js"></script> -->'
    ),
]

changed = False
for old, new in replacements:
    if old in text:
        text = text.replace(old, new)
        changed = True

if not changed:
    raise SystemExit("No expected script tags found to disable; aborting.")

path.write_text(text)
print("Disabled nonessential polling-heavy scripts in public/index.html for Matilda isolation probe.")
PY

docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo
echo "=== VERIFY REDUCED SCRIPT LOAD ==="
curl -sS http://127.0.0.1:8080/ | grep -n 'phase64_agent_activity_wire\|phase61_recent_history_wire\|dashboard-graph\|phase457_restore_task_panels\|operatorGuidance.sse' || true

echo
echo "=== OPEN CLEAN ROOT SESSION ==="
open -na "Google Chrome" --args --incognito http://localhost:8080/

git add public/index.html
git commit -m "Temporarily disable nonessential dashboard pollers for Matilda isolation probe"
git push
