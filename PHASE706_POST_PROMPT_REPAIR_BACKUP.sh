
#!/bin/bash

set -euo pipefail

echo "===== PHASE 706 POST-PROMPT-REPAIR BACKUP ====="

./PHASE705_EXTERNAL_BACKUP.sh phase706-post-prompt-repair-stable

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

echo "===== VERIFY CHAT CONTRACT ====="

curl -sS -X POST "http://localhost:3000/api/chat" \

  -H "Content-Type: application/json" \

  -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "===== VERIFY STORAGE ====="

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

echo ""

echo "===== BACKUP COMPLETE ====="

