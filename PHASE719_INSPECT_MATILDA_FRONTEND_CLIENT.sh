
#!/usr/bin/env bash

set -euo pipefail

rm -f PHASE719_ADD_MATILDA_CHAT_ROUTE_LOGGING.sh

echo "===== PHASE 719 INSPECT MATILDA FRONTEND CLIENT ====="

echo ""

echo "[1] Locate frontend fallback text"

grep -RInE "could not reach the chat service|no execution was attempted|api/chat|fetch\\(|chat service|input|message" public/js public/*.html ui/dashboard 2>/dev/null | head -120 || true

echo ""

echo "[2] Chat frontend files"

find public ui/dashboard -type f 2>/dev/null | grep -Ei "(matilda|chat|console).*\\.(js|html)$" | sort || true

echo ""

echo "[3] Repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add -A

git commit -m "Phase 719: inspect Matilda frontend client"

git push origin dev

