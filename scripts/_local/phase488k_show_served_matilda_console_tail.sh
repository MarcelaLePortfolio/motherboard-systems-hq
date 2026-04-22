#!/bin/bash
set -euo pipefail

echo "=== SERVED matilda-chat-console.js (relevant section) ==="
curl -sS http://127.0.0.1:8080/js/matilda-chat-console.js | sed -n '55,125p'

echo
echo "=== NEXT ==="
echo "Hard refresh the browser, click Quick check once, then paste the full console output."
