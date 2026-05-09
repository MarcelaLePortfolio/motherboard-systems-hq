
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 RETRY UI WIRING PRECHECK ====="

echo ""

echo "[1] Git checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Confirm verified retry contract artifact"

test -f PHASE717_RETRY_CONTRACT_VERIFIED.md

grep -n "POST /api/delegate-task\|meta.*retry_of_task_id\|explicit operator-triggered" PHASE717_RETRY_CONTRACT_VERIFIED.md || true

echo ""

echo "[3] Confirm active Docker dashboard entrypoint"

grep -n "command:.*server.js\|node.*server.js" docker-compose.yml Dockerfile.dashboard 2>/dev/null || true

echo ""

echo "[4] Locate lifecycle card renderer and disabled retry placeholders"

grep -n "lifecycle\|operator-actions\|Retry\|retry\|disabled" public/js/phase530_visible_panels_bridge.js | head -80

echo ""

echo "[5] Confirm no broad CSS retry dependency"

grep -R "operator-actions\|retry-action\|retry differently" -n public/css public/js 2>/dev/null | head -80 || true

echo ""

echo "[6] Runtime route smoke check"

curl -sS http://localhost:3000/api/tasks | head -c 500

echo ""

echo ""

echo "===== PRECHECK COMPLETE ====="

