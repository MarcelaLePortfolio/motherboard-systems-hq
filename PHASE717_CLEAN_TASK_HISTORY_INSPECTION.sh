
#!/bin/bash

set -e

echo "===== PHASE 717 CLEAN TASK HISTORY INSPECTION ====="

echo ""

echo "[1] Current checkpoint"

git status --short

git log --oneline --decorate -6

echo ""

echo "[2] Exact Telemetry Console HTML block"

nl -ba public/index.html | sed -n '368,410p'

echo ""

echo "[3] Task History source references"

grep -n 'Task History' public/index.html || true

grep -n 'obs-tab-activity' public/index.html || true

grep -n 'obs-panel-activity' public/index.html || true

grep -n 'task-activity-card' public/index.html || true

grep -n 'task-activity-graph' public/index.html || true

echo ""

echo "[4] JS references"

grep -R -n 'task-activity-graph' public/js public/*.js 2>/dev/null || true

grep -R -n 'task-activity-card' public/js public/*.js 2>/dev/null || true

grep -R -n 'obs-panel-activity' public/js public/*.js 2>/dev/null || true

grep -R -n 'obs-tab-activity' public/js public/*.js 2>/dev/null || true

echo ""

echo "[5] Served dashboard references"

curl -sS http://localhost:3000/ > /tmp/phase717_task_history_served.html

grep -n 'Task History' /tmp/phase717_task_history_served.html || true

grep -n 'obs-tab-activity' /tmp/phase717_task_history_served.html || true

grep -n 'obs-panel-activity' /tmp/phase717_task_history_served.html || true

grep -n 'task-activity-card' /tmp/phase717_task_history_served.html || true

grep -n 'task-activity-graph' /tmp/phase717_task_history_served.html || true

echo ""

echo "[6] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "===== CLEAN TASK HISTORY INSPECTION COMPLETE ====="

