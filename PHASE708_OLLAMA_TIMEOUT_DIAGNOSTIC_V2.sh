
#!/bin/bash

set -euo pipefail

echo "PHASE 708 — OLLAMA TIMEOUT DIAGNOSTIC V2"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Dashboard health"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[3] Direct Ollama probe from dashboard container"

docker compose exec -T dashboard sh -lc 'wget -qO- http://host.docker.internal:11434/api/tags | head -c 500' || true

echo ""

echo "[4] Direct Ollama generation from dashboard container"

docker compose exec -T dashboard sh -lc 'wget -qO- --header="Content-Type: application/json" --post-data='\''{"model":"gemma3:4b","prompt":"Reply briefly: systems check advisory only.","stream":false}'\'' http://host.docker.internal:11434/api/generate' | jq '{response,done}' || true

echo ""

echo "[5] Timed chat request"

time curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq . || true

echo ""

echo "[6] Dashboard logs"

docker compose logs --tail=100 dashboard

echo ""

echo "[7] Git status"

git status --short

git add PHASE708_OLLAMA_TIMEOUT_DIAGNOSTIC.sh PHASE708_OLLAMA_TIMEOUT_DIAGNOSTIC_V2.sh

git commit -m "Phase 708: fix Ollama timeout diagnostic script" || true

git push || true

