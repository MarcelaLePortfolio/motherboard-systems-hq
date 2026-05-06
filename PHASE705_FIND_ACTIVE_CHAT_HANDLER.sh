#!/bin/bash
set -euo pipefail

echo "PHASE 705 — FIND ACTIVE CHAT HANDLER"

echo ""
echo "[1] Inspect active server route registrations"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=.git \
  --exclude-dir=snapshots \
  "api/chat\|Advisory response only: received input" \
  server.js server.mjs server 2>/dev/null | head -40

echo ""
echo "[2] Compare suspected handlers"
echo "--- server/api/chat.mjs ---"
sed -n '1,90p' server/api/chat.mjs

echo ""
echo "--- server.mjs chat block ---"
grep -n -A35 -B10 "api/chat\|Advisory response only" server.mjs | head -80

echo ""
echo "--- server.js chat block ---"
grep -n -A35 -B10 "api/chat\|Advisory response only" server.js | head -80

echo ""
echo "[3] Live contract remains safe"
curl -sS -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are your execution boundaries?"}' | jq '{reply,meta}'

echo ""
echo "DONE"
