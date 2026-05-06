
#!/bin/bash

set -euo pipefail

echo "PHASE 707 — CLEAN FAILED CONTEXT PATCH ARTIFACTS"

rm -f PHASE707_INJECT_CONTEXT_DIRECT_PATCH.sh

rm -f PHASE707_INJECT_CONTEXT_LINE_PATCH.sh

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[3] Chat safety"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[4] Git status"

git status --short

git add -A

git commit -m "Phase 707: remove failed context injection patch artifacts" || true

git push || true

