
#!/bin/bash

set -euo pipefail

echo "PHASE 709 — PROMPT ASSEMBLY INSPECTION"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Inspect /api/chat implementation"

grep -nE "prompt|context|ollama|generate|system|advisory" server.js server.mjs routes/api-chat.ts 2>/dev/null || true

echo ""

echo "[3] Inspect Matilda frontend transport"

grep -nE "/api/chat|message|reply|fetch" public/js/matilda-chat-console.js public/index.html public/dashboard.html 2>/dev/null || true

echo ""

echo "[4] Inspect live context payload"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[5] Backend advisory response"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Summarize the current dashboard runtime state briefly."}' | jq .

echo ""

echo "[6] Git status"

git status --short

echo ""

echo "Inspection only. No mutations performed."

