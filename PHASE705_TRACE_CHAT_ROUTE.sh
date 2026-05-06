#!/bin/bash
set -euo pipefail

echo "PHASE 705 — TRACE ACTIVE CHAT ROUTE"

echo ""
echo "[1] Locate active /api/chat implementation"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=.git \
  --exclude-dir=_snapshots \
  "api/chat\|execution:false\|advisory-deterministic" \
  server app routes . 2>/dev/null | head -80

echo ""
echo "[2] Inspect likely primary file"
sed -n '1,260p' server/api/chat.mjs

echo ""
echo "[3] Live response sample"
curl -sS -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Summarize your purpose in two sentences."}' | jq .

echo ""
echo "TRACE COMPLETE"
