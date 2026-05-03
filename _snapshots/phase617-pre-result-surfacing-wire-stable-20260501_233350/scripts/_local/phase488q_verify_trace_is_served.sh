#!/bin/bash
set -euo pipefail

echo "=== VERIFY SERVED TRACE MARKERS ==="
curl -sS http://127.0.0.1:8080/js/matilda-chat-console.js | \
grep -n 'PHASE488_TRACE\|DEBUG_FETCH_WRAP\|response received\|parsed json' || true

echo
echo "=== NEXT ==="
echo "1. Hard refresh the browser"
echo "2. Click Quick check once"
echo "3. Paste the full console output"
