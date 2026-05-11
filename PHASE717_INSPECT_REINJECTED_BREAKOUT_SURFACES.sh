
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 REINJECTED BREAKOUT SURFACES INSPECTION ====="

echo ""

echo "[1] Checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Active dashboard script tags"

curl -sS http://localhost:3000/ | grep -o '<script[^>]*src="[^"]*"[^>]*>' | sed -n '1,120p'

echo ""

echo "[3] Active dashboard breakout references"

curl -sS http://localhost:3000/ > /tmp/phase717_served_dashboard.html

grep -n "Execution Inspector: Connected\|PHASE490 HEIGHTS\|task-events-card\|mb-task-events-panel-anchor\|obs-panel-events\|observational-workspace-card\|task-events-sse-client\|phase490_telemetry_height_probe" /tmp/phase717_served_dashboard.html || true

echo ""

echo "[4] Active public JS owners"

grep -R "Execution Inspector: Connected\|PHASE490 HEIGHTS\|task-events-card\|mb-task-events-panel-anchor\|obs-panel-events\|observational-workspace-card\|phase490_telemetry_height_probe" -n public/js public/*.js public/index.html \

  2>/dev/null | head -160

echo ""

echo "[5] Current served JS candidates"

for f in \

  /js/phase490_telemetry_height_probe.js \

  /js/task-events-sse-client.js \

  /js/phase530_visible_panels_bridge.js \

  /dashboard.js \

  /bundle-core.js

do

  echo "--- $f"

  curl -sS "http://localhost:3000$f" | grep -n "Execution Inspector: Connected\|PHASE490 HEIGHTS\|task-events-card\|mb-task-events-panel-anchor\|obs-panel-events\|observational-workspace-card" | head -80 || true

done

echo ""

echo "===== INSPECTION COMPLETE ====="

