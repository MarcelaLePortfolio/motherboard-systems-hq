
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 RETRY CONTRACT DISCOVERY ====="

echo ""

echo "[1] Retry contract references"

grep -RInE "retry_of_task_id|enforceRetryContract|delegate-task|/api/tasks/create" \

  app server routes src scripts \

  2>/dev/null | head -40 || true

echo ""

echo "[2] Route probe status only"

for route in \

  "/api/tasks/create" \

  "/api/delegate-task"

do

  printf "%s -> " "$route"

  curl -s -o /dev/null -w "%{http_code}\n" "http://localhost:3000$route" || true

done

echo ""

echo "===== COMPLETE ====="

