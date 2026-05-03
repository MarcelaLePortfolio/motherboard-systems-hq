#!/bin/bash
set -euo pipefail

echo "=== VERIFY /dashboard REDIRECT ==="
curl -I -sS http://127.0.0.1:8080/dashboard | head -n 10

echo
echo "=== VERIFY ROOT LOAD ==="
curl -sS http://127.0.0.1:8080/ | grep -n 'matilda-chat-root\|Operator Workspace' | head -n 10

echo
echo "=== MANUAL STEP ==="
echo "1. Browser should already be open (incognito)"
echo "2. Hard refresh (Cmd+Shift+R)"
echo "3. Open DevTools Console"
echo "4. Click 'Quick check'"
echo
echo "=== EXPECTED ==="
echo "[matilda-chat][DEBUG] handleSend triggered"
echo "[matilda-chat][DEBUG] sending request"
echo "[matilda-chat][DEBUG] response received"
echo "[matilda-chat][DEBUG] appending reply"
echo
echo "If NO response logs appear → report immediately"
echo "If response logs appear but no UI → DOM issue"
echo "If nothing triggers → event binding issue"
