
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 MATILDA CHAT SERVICE INSPECTION FIXED ====="

echo ""

echo "[1] Runtime containers"

docker compose ps

echo ""

echo "[2] Chat route fallback anchors"

grep -nE "host.docker.internal:11434|api/generate|AbortController|fallback|no message received|input" server.js server.mjs 2>/dev/null | head -80 || true

echo ""

echo "[3] Dashboard API route probe with input"

curl -sS -X POST http://localhost:3000/api/chat -H "Content-Type: application/json" -d '{"input":"what can i build with this system?"}' | python3 -m json.tool || true

echo ""

echo "[4] Dashboard API route probe with message"

curl -sS -X POST http://localhost:3000/api/chat -H "Content-Type: application/json" -d '{"message":"what can i build with this system?"}' | python3 -m json.tool || true

echo ""

echo "[5] Ollama reachability from host"

curl -sS http://localhost:11434/api/tags | head -40 || true

echo ""

echo "[6] Ollama reachability from dashboard container"

docker compose exec -T dashboard sh -lc 'wget -qO- http://host.docker.internal:11434/api/tags | head -40' || true

echo ""

echo "[7] Recent dashboard logs mentioning chat/Ollama"

docker compose logs --tail=120 dashboard | grep -Ei "chat|ollama|11434|abort|error|ECONN|fetch" || true

echo ""

echo "[8] Repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_MATILDA_CHAT_SERVICE_INSPECTION.sh PHASE719_MATILDA_CHAT_SERVICE_INSPECTION_FIXED.sh

git commit -m "Phase 719: inspect Matilda chat service with fixed probe"

git push origin dev

