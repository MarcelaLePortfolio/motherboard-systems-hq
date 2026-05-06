
#!/bin/bash

set -euo pipefail

echo "PHASE 707 — INSPECT CURRENT MATILDA PROMPT BLOCK"

echo ""

echo "[1] Current generator block in server.mjs"

grep -n -A90 -B10 "async function generateMatildaAdvisoryReply" server.mjs

echo ""

echo "[2] Current generator block in server.js"

grep -n -A90 -B10 "async function generateMatildaAdvisoryReply" server.js

echo ""

echo "[3] Git status"

git status --short

echo ""

echo "[4] Runtime"

docker compose ps

git add PHASE707_INJECT_READONLY_CONTEXT_INTO_CHAT.sh PHASE707_INSPECT_CURRENT_PROMPT_BLOCK.sh

git commit -m "Phase 707: inspect current Matilda prompt block" || true

git push || true

