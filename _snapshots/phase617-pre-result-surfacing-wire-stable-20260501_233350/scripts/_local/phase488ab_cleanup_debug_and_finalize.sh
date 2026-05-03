#!/bin/bash
set -euo pipefail

echo "=== CLEANUP: REMOVE TEMP DEBUG LOGGING FROM MATILDA CHAT ==="

# Remove PHASE488 trace + debug logs safely
sed -i '' '/PHASE488_TRACE/d' public/js/matilda-chat-console.js || true
sed -i '' '/DEBUG_FETCH_WRAP/d' public/js/matilda-chat-console.js || true
sed -i '' '/\[matilda-chat\]\[DEBUG/d' public/js/matilda-chat-console.js || true
sed -i '' '/PHASE488_TIMEOUT/d' public/js/matilda-chat-console.js || true

echo "=== REBUILD DASHBOARD ==="
docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo
echo "=== VERIFY CLEAN STATE ==="
curl -sS http://127.0.0.1:8080/js/matilda-chat-console.js | \
grep -n 'PHASE488\|DEBUG_FETCH_WRAP\|timeout or network failure' || echo "Clean"

echo
echo "=== OPEN FINAL CLEAN SESSION ==="
open -na "Google Chrome" --args --incognito http://localhost:8080/

echo
echo "=== DONE ==="
echo "Matilda should now respond normally with no debug noise."

git add public/js/matilda-chat-console.js
git commit -m "Remove temporary debug + timeout instrumentation after Matilda fix"
git push
