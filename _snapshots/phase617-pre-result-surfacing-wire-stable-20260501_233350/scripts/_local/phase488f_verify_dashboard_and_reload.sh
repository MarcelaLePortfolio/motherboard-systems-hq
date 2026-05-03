#!/bin/bash
set -euo pipefail

echo "=== CURRENT COMMIT ==="
git rev-parse --short HEAD

echo
echo "=== WAIT FOR CONTAINER STABILITY ==="
sleep 3

echo
echo "=== VERIFY DASHBOARD BUNDLE + MATILDA SCRIPT ==="
curl -sS http://127.0.0.1:8080/dashboard | grep -n 'dashboard-bundle-entry\|matilda-chat-console' | head -n 20 || true

echo
echo "=== OPEN CLEAN DASHBOARD SESSION ==="
open -na "Google Chrome" --args --incognito http://localhost:8080/dashboard

echo
echo "=== INSTRUCTIONS ==="
echo "1. Hard refresh (Cmd+Shift+R)"
echo "2. Open DevTools Console"
echo "3. Click 'Quick check'"
echo "4. Confirm you see:"
echo "   [matilda-chat][DEBUG] handleSend triggered"
echo "   [matilda-chat][DEBUG] response received"
echo "   Matilda reply appended"
