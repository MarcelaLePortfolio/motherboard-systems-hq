
#!/bin/bash

set -euo pipefail

echo "PHASE 707 — RESTORE FROM STABLE AFTER CONTEXT PATCH FAILURE"

STABLE_COMMIT="becacb1f"

echo ""

echo "[1] Restore server files from stable pre-context-injection checkpoint"

git checkout "$STABLE_COMMIT" -- server.mjs server.js

echo ""

echo "[2] Syntax check restored files"

node --check server.mjs

node --check server.js

echo ""

echo "[3] Rebuild dashboard from restored stable files"

docker compose up -d --build dashboard

echo ""

echo "[4] Wait for HTTP"

for i in $(seq 1 30); do

  if curl -sS -I "http://localhost:3000" >/dev/null 2>&1; then

    echo "Dashboard HTTP ready"

    break

  fi

  echo "waiting... $i"

  sleep 2

done

echo ""

echo "[5] Validate restored chat/context state"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[6] Runtime"

docker compose ps

echo ""

echo "[7] Git status"

git status --short

git add server.mjs server.js PHASE707_RESTORE_FROM_STABLE_AFTER_CONTEXT_PATCH.sh

git commit -m "Phase 707: restore stable server after context patch failure"

git push

