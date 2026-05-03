#!/bin/bash
set -euo pipefail

echo "=== CURRENT COMMIT ==="
git rev-parse --short HEAD

echo
echo "=== SERVED MATILDA GUARD CHECK ==="
curl -sS http://127.0.0.1:8080/js/matilda-chat-console.js | \
grep -n 'let inFlight = false\|PHASE488_GUARD\|fetchWithTimeout\|timeout or network failure' || true

echo
echo "=== DIRECT API CHECK ==="
curl -sS -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"single-flight verify","agent":"matilda"}' | python3 -m json.tool || true

echo
echo "=== OPEN CLEAN SESSION ==="
open -na "Google Chrome" --args --incognito --auto-open-devtools-for-tabs http://localhost:8080/

echo
echo "=== MANUAL CHECK ==="
echo "1. Hard refresh"
echo "2. Click Quick check once"
echo "3. Record exactly one result:"
echo "   REPLY WORKED"
echo "   TIMEOUT HIT"
echo "   NO UI CHANGE"
