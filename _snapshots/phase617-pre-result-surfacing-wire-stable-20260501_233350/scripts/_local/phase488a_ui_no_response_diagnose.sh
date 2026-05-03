#!/bin/bash
set -euo pipefail

echo "=== HEAD ==="
git rev-parse --short HEAD

echo
echo "=== confirm API works ==="
curl -sS -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"ui check","agent":"matilda"}' | python3 -m json.tool

echo
echo "=== check frontend calling /api/chat ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/chat' public || true

echo
echo "=== check for fetch/axios usage ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git 'fetch(\|axios' public || true

echo
echo "=== check matilda console wiring ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git 'matilda' public/js || true

echo
echo "=== container logs (last 50 lines) ==="
docker logs motherboard_systems_hq-dashboard-1 --tail 50 || true
