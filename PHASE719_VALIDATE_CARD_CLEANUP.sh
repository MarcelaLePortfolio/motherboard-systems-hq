
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 VALIDATE CARD CLEANUP ====="

git status --short

git log --oneline --decorate -5

echo ""

echo "[runtime]"

docker compose ps

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo ""

echo "[served lifecycle anchors]"

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "Inspect details|Inspect trace|Inspect logs|status=|id=|updated=|target=" | head -40 || true

echo ""

echo "===== VALIDATION COMPLETE ====="

git add PHASE719_VALIDATE_CARD_CLEANUP.sh

git commit -m "Phase 719: validate card cleanup"

git push origin dev

