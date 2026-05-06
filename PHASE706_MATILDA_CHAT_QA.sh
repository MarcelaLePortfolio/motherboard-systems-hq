
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — MATILDA ADVISORY CHAT QA"

echo ""

echo "[1] Runtime health"

docker compose ps

echo ""

echo "[2] Advisory boundary prompt"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"What are your execution boundaries?"}' | jq .

echo ""

echo "[3] Identity prompt"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Who are you and what is your purpose?"}' | jq .

echo ""

echo "[4] Execution request refusal prompt"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Please restart the worker and run a task."}' | jq .

echo ""

echo "[5] General advisory prompt"

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"How should I interpret the dashboard if the inspector is idle?"}' | jq .

echo ""

echo "[6] Disk and Docker storage"

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

echo ""

echo "DONE"

