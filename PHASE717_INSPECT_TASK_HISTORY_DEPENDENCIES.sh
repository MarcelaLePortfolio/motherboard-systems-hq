
#!/bin/bash

set -e

echo "===== PHASE 717 INSPECT TASK HISTORY DEPENDENCIES ====="

echo ""

echo "[1] Current checkpoint"

git status --short

git log --oneline --decorate -6

echo ""

echo "[2] Task History HTML ownership"

grep -n -B3 -A12 \

'obs-tab-activity\|obs-panel-activity\|task-activity-card\|task-activity-graph' \

public/index.html || true

echo ""

echo "[3] JS dependencies"

grep -R -n \

'task-activity-graph\|obs-panel-activity\|task-activity-card' \

public/js public/*.js 2>/dev/null | head -120 || true

echo ""

echo "[4] CSS/layout dependencies"

grep -n -B2 -A4 \

'task-activity-card\|task-activity-graph\|obs-panel-activity' \

public/index.html | head -220 || true

echo ""

echo "[5] Served dashboard references"

curl -sS http://localhost:3000/ | grep -n -B2 -A6 \

'Task History\|task-activity-card\|task-activity-graph\|obs-panel-activity' \

| head -220 || true

echo ""

echo "[6] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}"

echo ""

echo "===== TASK HISTORY DEPENDENCY INSPECTION COMPLETE ====="

