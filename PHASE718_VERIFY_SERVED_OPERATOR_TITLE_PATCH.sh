
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

SERVED_FILE="/tmp/phase718_served_renderer.js"

echo "===== PHASE 718 SERVED OPERATOR TITLE PATCH VERIFY ====="

echo ""

echo "[1] Local patch anchors"

grep -nE "rawTitle|operatorTitle|targetTitle|target=" "$TARGET" | head -20 || true

echo ""

echo "[2] Locate renderer reference from dashboard HTML"

curl -fsS http://localhost:3000 > /tmp/phase718_dashboard.html

grep -oE 'src="[^"]*phase530_visible_panels_bridge.js[^"]*"' /tmp/phase718_dashboard.html || true

echo ""

echo "[3] Fetch served renderer directly"

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js > "$SERVED_FILE"

echo ""

echo "[4] Served patch anchors"

grep -nE "rawTitle|operatorTitle|targetTitle|target=" "$SERVED_FILE" | head -20 || true

echo ""

echo "[5] Decision"

if grep -q "operatorTitle" "$SERVED_FILE"; then

  echo "PASS: served renderer contains operator title patch"

else

  echo "MISS: served renderer does not contain operator title patch"

  echo "Restarting dashboard container to pick up patched public JS..."

  docker compose restart dashboard

  sleep 5

  curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js > "$SERVED_FILE"

  grep -nE "rawTitle|operatorTitle|targetTitle|target=" "$SERVED_FILE" | head -20 || true

fi

echo ""

echo "[6] Final runtime check"

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo "dashboard + /api/tasks: PASS"

echo ""

echo "===== VERIFY COMPLETE ====="

git add PHASE718_VERIFY_SERVED_OPERATOR_TITLE_PATCH.sh

git commit -m "Phase 718: verify served operator title patch"

git push origin dev

