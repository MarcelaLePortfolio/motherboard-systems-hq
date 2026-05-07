
#!/bin/bash

set -euo pipefail

echo "PHASE 708 — FRONTEND CHAT TIMEOUT FALLBACK INSPECTION"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Locate frontend Matilda chat files"

find . -path "./node_modules" -prune -o -path "./.git" -prune -o -path "./_snapshots" -prune -o -path "./snapshots" -prune -o -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.html" \) -print | xargs grep -nE "Chat with Matilda|/api/chat|timeout or network failure|Matilda:" || true

echo ""

echo "[3] Inspect likely public dashboard files"

for file in public/index.html public/dashboard.html public/app.js public/script.js public/main.js app/page.tsx app/components/MatildaChat.tsx components/MatildaChat.tsx

do

  if [ -f "$file" ]; then

    echo ""

    echo "===== $file ====="

    grep -nE "Matilda|/api/chat|timeout|network|fetch" "$file" || true

  fi

done

echo ""

echo "[4] Backend chat sanity"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[5] Context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[6] Git status"

git status --short

echo ""

echo "DONE"

git add PHASE708_FRONTEND_CHAT_TIMEOUT_FALLBACK_INSPECTION.sh

git commit -m "Phase 708: fix frontend chat timeout fallback inspection script" || true

git push || true

