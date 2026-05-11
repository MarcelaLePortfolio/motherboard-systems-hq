
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 TARGET VISIBLE BREAKOUT SURFACES ====="

echo ""

echo "[1] Stable checkpoint"

git status --short

git log --oneline --decorate -6

echo ""

echo "[2] Current active dashboard telemetry/workspace blocks"

grep -n -B4 -A10 'observational-workspace-card\|obs-panel-events\|task-events-card\|mb-task-events-panel-anchor\|Recent Tasks\|Task Events\|Execution Inspector\|PHASE490 HEIGHTS' public/index.html | sed -n '1,220p'

echo ""

echo "[3] Active probe/debug script tags"

grep -n 'phase490\|phase530_dom_probe\|phase573_execution_inspector_debug\|task-events-sse-client\|phase457_restore_task_panels' public/index.html

echo ""

echo "[4] Served visible/debug markers"

curl -sS http://localhost:3000/ | grep -n -B3 -A8 'PHASE490 HEIGHTS\|Execution Inspector\|Recent Tasks\|Task Events\|task-events-card\|mb-task-events-panel-anchor' | sed -n '1,220p'

echo ""

echo "[5] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}"

echo ""

echo "===== INSPECTION COMPLETE ====="

