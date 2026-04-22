#!/bin/bash
set -euo pipefail

echo "=== CURRENT COMMIT ==="
git rev-parse --short HEAD

echo
echo "=== SERVED TIMEOUT GUARD CHECK ==="
curl -sS http://127.0.0.1:8080/js/matilda-chat-console.js | \
grep -n 'fetchWithTimeout\|PHASE488_TIMEOUT\|timeout or network failure' || true

echo
echo "=== DIRECT API SANITY ==="
curl -sS -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"post-timeout-guard sanity","agent":"matilda"}' | python3 -m json.tool || true

echo
echo "=== NEXT MANUAL CHECK ==="
echo "In the browser, click Quick check once."
echo "If Matilda replies, report: REPLY WORKED"
echo "If the transcript shows '(timeout or network failure)' after ~5s, report: TIMEOUT HIT"
echo "If neither appears, report: NO UI CHANGE"
