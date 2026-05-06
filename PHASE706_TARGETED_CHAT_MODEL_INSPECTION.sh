
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — TARGETED CHAT MODEL INSPECTION"

echo ""

echo "[1] Active chat route block in server.mjs"

grep -n -A70 -B10 "api/chat" server.mjs | head -100

echo ""

echo "[2] Existing Ollama helper"

if [ -f "ollamaChat.ts" ]; then

  sed -n '1,160p' ollamaChat.ts

else

  echo "ollamaChat.ts not found"

fi

echo ""

echo "[3] Existing Matilda chat helper"

if [ -f "matilda_chat.ts" ]; then

  sed -n '1,160p' matilda_chat.ts

else

  echo "matilda_chat.ts not found"

fi

echo ""

echo "[4] Runtime health"

docker compose ps

echo ""

echo "[5] Git status"

git status --short

echo ""

echo "DONE"

