
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 718 LINEAGE LABEL VALIDATION ====="

echo ""

echo "[1] Git status"

git status --short

git log --oneline --decorate -3

echo ""

echo "[2] Docker containers"

docker compose ps

echo ""

echo "[3] Renderer syntax"

node --check "$TARGET"

echo ""

echo "[4] Local renderer anchors"

grep -nE "strategy:|retry of:|executionStrategy|retryOf" "$TARGET" | head -12

echo ""

echo "[5] Dashboard root"

curl -fsS http://localhost:3000 >/dev/null

echo "dashboard root: PASS"

echo ""

echo "[6] Tasks API"

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo "/api/tasks: PASS"

echo ""

echo "===== LINEAGE LABEL VALIDATION COMPLETE ====="

