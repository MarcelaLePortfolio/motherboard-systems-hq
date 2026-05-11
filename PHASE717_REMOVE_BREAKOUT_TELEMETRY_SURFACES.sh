
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 REMOVE BREAKOUT TELEMETRY SURFACES ====="

echo ""

echo "[1] Safety checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Remove legacy observational workspace + task-events breakout shell from active dashboard"

python3 << 'PY'

from pathlib import Path

import re

p = Path("public/index.html")

s = p.read_text()

patterns = [

    r'<section id="observational-workspace-card".*?</section>\s*</section>',

    r'<div id="obs-panel-events".*?</div>\s*</div>',

    r'<section id="task-events-card".*?</section>',

    r'<div id="mb-task-events-panel-anchor"></div>',

    r'<button id="obs-tab-events".*?</button>',

]

for pat in patterns:

    s = re.sub(pat, '', s, flags=re.S)

s = re.sub(

    r'\s*<script id="phase61-task-events-polish-script">.*?</script>',

    '\n',

    s,

    flags=re.S

)

s = re.sub(

    r'\s*<style id="phase61-task-events-polish">.*?</style>',

    '\n',

    s,

    flags=re.S

)

p.write_text(s)

print("Active dashboard breakout telemetry surfaces removed.")

PY

echo ""

echo "[3] Rebuild dashboard"

docker compose restart dashboard

echo ""

echo "[4] Wait for runtime"

sleep 8

echo ""

echo "[5] Validate served dashboard no longer contains breakout telemetry surfaces"

curl -sS http://localhost:3000/ | grep -E \

'Execution Inspector: Connected|PHASE490 HEIGHTS|obs-panel-events|task-events-card|mb-task-events-panel-anchor|observational-workspace-card' \

&& echo "UNEXPECTED BREAKOUT REFERENCES STILL PRESENT" \

|| echo "Breakout telemetry surfaces removed successfully."

echo ""

echo "[6] Confirm Recent Tasks still exists"

curl -sS http://localhost:3000/ | grep 'id="recentTasks"' \

&& echo "Recent Tasks preserved." \

|| echo "WARNING: Recent Tasks missing."

echo ""

echo "[7] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "===== PHASE 717 BREAKOUT TELEMETRY REMOVAL COMPLETE ====="

