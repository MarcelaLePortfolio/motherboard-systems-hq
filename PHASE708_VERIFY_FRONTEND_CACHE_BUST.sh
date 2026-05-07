
#!/bin/bash

set -euo pipefail

echo "PHASE 708 — VERIFY FRONTEND CACHE BUST"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Verify served frontend fallback text"

curl -sS "http://localhost:3000/js/matilda-chat-console.js?cachebust=$(date +%s)" | grep -n "could not reach the chat service"

echo ""

echo "[3] Backend chat sanity"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[4] Context endpoint sanity"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[5] Git status"

git status --short

git add PHASE708_FORCE_FRONTEND_CACHE_BUST.sh PHASE708_VERIFY_FRONTEND_CACHE_BUST.sh

git commit -m "Phase 708: verify frontend cache-busted Matilda fallback" || true

git push || true

echo ""

echo "Now hard refresh the browser with CMD + SHIFT + R, then retry Matilda from the dashboard UI."

