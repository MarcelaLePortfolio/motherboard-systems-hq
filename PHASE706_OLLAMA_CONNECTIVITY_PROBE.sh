
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — OLLAMA CONNECTIVITY PROBE"

echo ""

echo "[1] Runtime health"

docker compose ps

echo ""

echo "[2] Host Ollama probe"

curl -sS http://localhost:11434/api/tags | jq . || true

echo ""

echo "[3] Dashboard container Ollama probe via host.docker.internal"

docker compose exec -T dashboard sh -lc 'wget -qO- http://host.docker.internal:11434/api/tags' | jq . || true

echo ""

echo "[4] Safe sample generate from host"

curl -sS -X POST "http://localhost:11434/api/generate" \

  -H "Content-Type: application/json" \

  -d '{"model":"gemma3:4b","prompt":"Reply in one sentence: Matilda is advisory-only and cannot execute tasks.","stream":false}' | jq '{response,done}' || true

echo ""

echo "[5] Current chat contract still deterministic"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Say hello naturally."}' | jq .

echo ""

echo "[6] Git status"

git status --short

echo ""

echo "DONE"

