
#!/bin/bash

set -euo pipefail

echo "PHASE 710 — PREPATCH TARGET VERIFICATION"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Verify current prompt block target in server.mjs"

grep -n -A20 -B5 "const promptLines = \[" server.mjs

echo ""

echo "[3] Verify current prompt block target in server.js"

grep -n -A20 -B5 "const promptLines = \[" server.js

echo ""

echo "[4] Verify context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[5] Verify current chat response"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Summarize the current dashboard runtime state briefly."}' | jq .

echo ""

echo "[6] Git status"

git status --short

echo ""

echo "DONE — inspection only, no runtime or source mutation except this script."

git add PHASE710_PREPATCH_TARGET_VERIFICATION.sh

git commit -m "Phase 710: verify Matilda prompt patch target before context injection" || true

git push || true

