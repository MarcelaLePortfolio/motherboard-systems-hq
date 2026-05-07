
#!/bin/bash

set -euo pipefail

echo "===== PHASE 708 CHAT TIMEOUT DIAGNOSTIC BACKUP ====="

./PHASE705_EXTERNAL_BACKUP.sh phase708-chat-timeout-diagnostic-stable

echo ""

echo "===== VERIFY LATEST SNAPSHOTS ====="

find "/Volumes/Rio Drive/Motherboard_Storage/snapshots" -maxdepth 1 -type d | sort | tail -5

echo ""

echo "===== VERIFY GIT HEAD ====="

git log --oneline -n 5

echo ""

echo "===== VERIFY RUNTIME ====="

docker compose ps

echo ""

echo "===== VERIFY CHAT CONTEXT ENDPOINT ====="

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "===== VERIFY CHAT ====="

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "===== VERIFY OLLAMA FROM DASHBOARD CONTAINER ====="

docker compose exec -T dashboard sh -lc 'wget -qO- --header="Content-Type: application/json" --post-data='\''{"model":"gemma3:4b","prompt":"Reply briefly: advisory only.","stream":false}'\'' http://host.docker.internal:11434/api/generate' | jq '{response,done}' || true

echo ""

echo "===== VERIFY STORAGE ====="

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

echo ""

echo "===== BACKUP COMPLETE ====="

