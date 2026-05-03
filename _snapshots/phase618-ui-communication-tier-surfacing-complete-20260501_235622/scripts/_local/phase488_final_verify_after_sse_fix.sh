#!/bin/bash
set -euo pipefail

echo "=== REBUILD + RESTART DASHBOARD ==="
docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo
echo "=== VERIFY SCRIPT IS SERVED ==="
curl -sS http://127.0.0.1:8080/ | grep -n 'phase488_fix_sse_singleton' || true

echo
echo "=== OPEN CLEAN TEST SESSION ==="
open -na "Google Chrome" --args --incognito --auto-open-devtools-for-tabs http://localhost:8080/

echo
echo "=== FINAL MANUAL CHECK ==="
echo "1. Hard refresh"
echo "2. Click 'Quick check' ONCE"
echo "3. Expect Matilda to respond normally (no timeout)"
echo
echo "Report back with:"
echo "REPLY WORKED"
echo "TIMEOUT HIT"
echo "NO UI CHANGE"
