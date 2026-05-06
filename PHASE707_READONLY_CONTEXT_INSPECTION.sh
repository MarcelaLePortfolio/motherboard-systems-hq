
#!/bin/bash

set -euo pipefail

echo "PHASE 707 — READ-ONLY CONTEXT INJECTION INSPECTION"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Existing health/status/guidance/task endpoints in server"

grep -nE "app\.(get|post)\('/api|app\.(get|post)\(\"/api|events/task-events|operator-guidance|guidance|health|tasks|status" server.mjs server.js | head -160

echo ""

echo "[3] Probe safe read-only endpoints"

for url in \

  "http://localhost:3000/api/health" \

  "http://localhost:3000/api/tasks" \

  "http://localhost:3000/api/guidance" \

  "http://localhost:3000/api/guidance/history" \

  "http://localhost:3000/api/guidance/coherence-shadow"

do

  echo ""

  echo "===== $url ====="

  curl -sS "$url" | jq 'if type=="array" then .[0:3] else . end' || true

done

echo ""

echo "[4] Current Matilda response"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[5] Git status"

git status --short

echo ""

echo "DONE"

