
#!/bin/bash

set -euo pipefail

echo "PHASE 708 — FORCE FRONTEND CACHE BUST"

echo ""

echo "[1] Verify patched frontend file"

grep -n "could not reach the chat service" public/js/matilda-chat-console.js

echo ""

echo "[2] Rebuild dashboard container with no cache"

docker compose build --no-cache dashboard

echo ""

echo "[3] Restart dashboard container"

docker compose up -d dashboard

echo ""

echo "[4] Wait for dashboard HTTP"

for i in $(seq 1 30)

do

  if curl -sS -I "http://localhost:3000" >/dev/null 2>&1; then

    echo "Dashboard HTTP ready"

    break

  fi

  echo "waiting... $i"

  sleep 2

done

echo ""

echo "[5] Backend sanity"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[6] Runtime"

docker compose ps

echo ""

echo "IMPORTANT:"

echo "Now hard refresh the browser:"

echo "Mac: CMD + SHIFT + R"

echo "Then retry Matilda from the dashboard UI."

git add PHASE708_FORCE_FRONTEND_CACHE_BUST.sh

git commit -m "Phase 708: force frontend cache bust for Matilda chat UI" || true

git push || true

