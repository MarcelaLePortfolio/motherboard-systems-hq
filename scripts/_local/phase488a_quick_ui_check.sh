#!/bin/bash
set -euo pipefail

echo "=== API sanity check ==="
curl -sS -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"ui check","agent":"matilda"}' | python3 -m json.tool

echo
echo "=== does frontend call /api/chat? ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/chat' public || echo "NO FRONTEND CALL FOUND"

echo
echo "=== any fetch/axios calls? ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git 'fetch(\|axios' public || echo "NO FETCH FOUND"

echo
echo "=== matilda wiring ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git 'matilda' public/js || true
