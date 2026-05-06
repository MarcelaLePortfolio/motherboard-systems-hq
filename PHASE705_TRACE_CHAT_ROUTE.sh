#!/bin/bash
set -euo pipefail

echo "[1] Chat route hits"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=.git \
  "advisory-deterministic\|execution:false" \
  server app . 2>/dev/null | head -20

echo ""
echo "[2] First 120 lines of primary route"
sed -n '1,120p' server/api/chat.mjs

echo ""
echo "[3] Live response"
curl -sS -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello"}' | jq '{reply,meta}'

echo ""
echo "DONE"
