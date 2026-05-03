#!/bin/bash
set -euo pipefail

echo "=== HEAD ==="
git rev-parse --short HEAD

echo
echo "=== verify served matilda-chat-console.js contains DOM-ready hardening ==="
curl -sS http://127.0.0.1:8080/js/matilda-chat-console.js | \
grep -n 'document.readyState === "loading"\|wireChat();'

echo
echo "=== verify served index contains matilda controls ==="
curl -sS http://127.0.0.1:8080/ | \
grep -n 'matilda-chat-root\|matilda-chat-input\|matilda-chat-send\|matilda-chat-quick-check' | head -n 20

echo
echo "=== next manual step ==="
echo "Hard refresh the browser with Cmd+Shift+R, then test Matilda Send and Quick check once."
