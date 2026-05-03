#!/bin/bash
set -euo pipefail

echo "=== API CHECK ==="
curl -sS -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"ui check","agent":"matilda"}' | python3 -m json.tool

echo
echo "=== FRONTEND CALL (FIRST MATCH ONLY) ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/chat' public | head -n 3 || echo "NO CALL FOUND"

echo
echo "=== FETCH USAGE (FIRST MATCH ONLY) ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git 'fetch(' public | head -n 3 || echo "NO FETCH FOUND"
