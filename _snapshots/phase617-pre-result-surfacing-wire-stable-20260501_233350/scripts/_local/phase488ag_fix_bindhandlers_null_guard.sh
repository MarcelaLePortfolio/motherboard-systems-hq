#!/bin/bash
set -euo pipefail

echo "=== PHASE488 SAFE FIX: GUARD bindHandlers NULL INPUT ==="

FILE="public/js/phase457_restore_task_panels.js"

# Insert null-guard directly before bindHandlers usage
sed -i '' '/bindHandlers(es);/c\
    if (!es) {\
      scheduleReconnect();\
      return;\
    }\
    bindHandlers(es);\
' "$FILE"

echo "=== VERIFY PATCH ==="
grep -n "scheduleReconnect\|bindHandlers(es)" "$FILE"

echo "=== REBUILD DASHBOARD ==="
docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo "=== DONE ==="
