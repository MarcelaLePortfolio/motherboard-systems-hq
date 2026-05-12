
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 718 OPERATOR TITLE VALIDATION ====="

echo ""

echo "[1] Git"

git status --short

git log --oneline --decorate -3

echo ""

echo "[2] Syntax"

node --check "$TARGET"

echo ""

echo "[3] Runtime"

docker compose ps

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo "dashboard + /api/tasks: PASS"

echo ""

echo "[4] Open dashboard for manual visual check"

open "http://localhost:3000"

echo ""

echo "Manual pass criteria:"

echo "- Retry task card title says: Retry differently"

echo "- Requeue task card title says: Requeue"

echo "- target=t_... appears only as smaller secondary metadata"

echo "- lifecycle badge still visible"

echo "- strategy/retry lineage badges still use consistent pill shapes"

echo "- Retry/Requeue buttons still visible"

echo "- No layout collapse or overflow regression"

echo ""

echo "===== VALIDATION COMPLETE ====="

