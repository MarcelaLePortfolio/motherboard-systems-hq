
#!/usr/bin/env bash

set -euo pipefail

SERVED_FILE="/tmp/phase718_served_renderer.js"

echo "===== PHASE 718 DASHBOARD REBUILD ====="

echo ""

echo "[1] Rebuild dashboard image only"

docker compose build dashboard

echo ""

echo "[2] Restart dashboard container only"

docker compose up -d dashboard

echo ""

echo "[3] Wait for dashboard readiness"

sleep 8

echo ""

echo "[4] Verify runtime"

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo "dashboard + /api/tasks: PASS"

echo ""

echo "[5] Verify served renderer patch"

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js > "$SERVED_FILE"

grep -nE "rawTitle|operatorTitle|targetTitle|target=" "$SERVED_FILE" | head -20 || true

echo ""

if grep -q "operatorTitle" "$SERVED_FILE"; then

  echo "PASS: served renderer now contains operator title normalization"

else

  echo "FAIL: served renderer still stale"

  exit 1

fi

echo ""

echo "[6] Open dashboard"

open "http://localhost:3000"

echo ""

echo "Expected result:"

echo "- Retry differently"

echo "- Requeue"

echo "- target=t_... secondary metadata"

echo "- consistent pill borders preserved"

echo ""

echo "===== REBUILD COMPLETE ====="

git add PHASE718_REBUILD_DASHBOARD_ONLY.sh

git commit -m "Phase 718: rebuild dashboard for operator titles"

git push origin dev

