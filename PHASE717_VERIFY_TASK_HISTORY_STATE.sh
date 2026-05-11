
#!/bin/bash

set -e

echo "===== PHASE 717 VERIFY TASK HISTORY STATE ====="

echo ""

echo "[1] Current checkpoint"

git status --short

git log --oneline --decorate -6

echo ""

echo "[2] Source Task History references"

grep -n 'Task History\|obs-tab-activity\|obs-panel-activity\|task-activity-card\|task-activity-graph' public/index.html || true

echo ""

echo "[3] Served Task History references"

curl -sS http://localhost:3000/ > /tmp/phase717_task_history_state.html

grep -n 'Task History\|obs-tab-activity\|obs-panel-activity\|task-activity-card\|task-activity-graph' /tmp/phase717_task_history_state.html || true

echo ""

echo "[4] Served preserved Recent Tasks references"

grep -n 'Telemetry Console\|Recent Tasks\|id="recentTasks"' /tmp/phase717_task_history_state.html || true

echo ""

echo "[5] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "===== VERIFY COMPLETE ====="

