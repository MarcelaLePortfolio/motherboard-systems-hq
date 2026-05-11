
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 BREAKOUT CONTAINER INSPECTION ====="

echo ""

echo "[1] Checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Search likely breakout/probe owners"

grep -R "Execution Inspector: Connected\|PHASE490 HEIGHTS\|task-events-card\|obs-panel-events\|mb-task-events\|operator-workspace-card\|observational-workspace-card\|task-events" -n public \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  | head -160

echo ""

echo "[3] Served dashboard breakout references"

curl -sS http://localhost:3000/ | grep -n "Execution Inspector\|PHASE490 HEIGHTS\|task-events-card\|obs-panel-events\|mb-task-events\|operator-workspace-card\|observational-workspace-card" | head -120 || true

echo ""

echo "[4] Served JS breakout references"

for f in /js/phase490_telemetry_height_probe.js /js/task-events-sse-client.js /js/phase530_visible_panels_bridge.js; do

  echo "--- $f"

  curl -sS "http://localhost:3000$f" | grep -n "PHASE490\|Execution Inspector\|task-events-card\|mb-task-events\|operator-workspace-card\|observational-workspace-card" | head -80 || true

done

echo ""

echo "===== INSPECTION COMPLETE ====="

