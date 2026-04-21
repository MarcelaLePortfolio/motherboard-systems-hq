#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — VERIFY MATILDA CHAT STUB LIVE"
echo "────────────────────────────────"

echo
echo "== git status --short =="
git status --short

echo
echo "== docker compose ps =="
docker compose ps

echo
echo "== POST /api/chat =="
curl -i -s -X POST http://localhost:8080/api/chat \
  -H 'Content-Type: application/json' \
  --data '{"message":"Quick systems check from dashboard Phase 11.4.","agent":"matilda"}' \
  | sed -n '1,120p'

echo
echo "== GET /api/chat (expected 404 if POST-only route) =="
curl -i -s http://localhost:8080/api/chat | sed -n '1,40p' || true

echo
echo "== recent dashboard logs =="
docker compose logs --tail=80 dashboard || true

echo
echo "────────────────────────────────"
echo "PHASE 487 — MATILDA CHAT LIVE VERIFICATION COMPLETE"
echo "────────────────────────────────"
