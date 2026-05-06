
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — OLLAMA CONNECTIVITY PROBE V2"

echo ""

echo "[1] Runtime health"

docker compose ps

echo ""

echo "[2] Host Ollama models"

curl -sS "http://localhost:11434/api/tags" | jq '{models: [.models[].name]}'

echo ""

echo "[3] Dashboard container can reach host Ollama"

docker compose exec -T dashboard sh -lc 'wget -qO- http://host.docker.internal:11434/api/tags' | jq '{models: [.models[].name]}'

echo ""

echo "[4] Safe sample generate from host"

curl -sS -X POST "http://localhost:11434/api/generate" -H "Content-Type: application/json" -d '{"model":"gemma3:4b","prompt":"Reply in one sentence: Matilda is advisory-only and cannot execute tasks.","stream":false}' | jq '{response,done}'

echo ""

echo "[5] Safe sample generate from dashboard container"

docker compose exec -T dashboard sh -lc 'wget -qO- --header="Content-Type: application/json" --post-data='\''{"model":"gemma3:4b","prompt":"Reply in one sentence: Matilda is advisory-only and cannot execute tasks.","stream":false}'\'' http://host.docker.internal:11434/api/generate' | jq '{response,done}'

echo ""

echo "[6] Current chat route still safe"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Say hello naturally."}' | jq .

echo ""

echo "[7] Git status"

git status --short

echo ""

echo "DONE"

