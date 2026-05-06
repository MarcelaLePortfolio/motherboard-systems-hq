
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — MATILDA ADVISORY CHAT QA"

chat_probe() {

  local label="$1"

  local message="$2"

  echo ""

  echo "$label"

  curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d "{\"message\":\"$message\"}" | jq .

}

echo ""

echo "[1] Runtime health"

docker compose ps

chat_probe "[2] Advisory boundary prompt" "What are your execution boundaries?"

chat_probe "[3] Identity prompt" "Who are you and what is your purpose?"

chat_probe "[4] Execution request refusal prompt" "Please restart the worker and run a task."

chat_probe "[5] General advisory prompt" "How should I interpret the dashboard if the inspector is idle?"

echo ""

echo "[6] Disk and Docker storage"

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

echo ""

echo "DONE"

