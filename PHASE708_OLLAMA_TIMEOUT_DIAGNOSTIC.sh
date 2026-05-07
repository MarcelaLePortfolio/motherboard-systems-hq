
#!/bin/bash

set -euo pipefail

echo "PHASE 708 — OLLAMA TIMEOUT DIAGNOSTIC"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Dashboard health"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[3] Direct Ollama probe from host"

curl -sS "http://localhost:11434/api/tags" | jq '.models[0:5]' || true

echo ""

echo "[4] Direct Ollama probe from dashboard container"

docker compose exec dashboard sh -lc \

'wget -qO- http://host.docker.internal:11434/api/tags | head -c 500' || true

echo ""

echo "[5] Timed chat request"

time curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Quick systems check from dashboard."}' | jq . || true

echo ""

echo "[6] Dashboard logs"

docker compose logs --tail=80 dashboard

echo ""

echo "[7] Git status"

git status --short

git add PHASE708_OLLAMA_TIMEOUT_DIAGNOSTIC.sh

git commit -m "Phase 708: add Ollama timeout diagnostic" || true

git push || true

