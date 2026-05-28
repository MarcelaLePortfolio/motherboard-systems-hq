
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_RESPONSE_ENRICHMENT_REVERT_CONFIRMATION.txt"

git checkout -- server/routes/api-tasks-postgres.mjs

docker compose build dashboard

docker compose up -d dashboard

sleep 2

{

  echo "===== TASK RESPONSE ENRICHMENT REVERT CONFIRMATION ====="

  date

  echo

  echo "===== DASHBOARD HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health || true

  echo

  echo "===== /api/tasks VERIFY ====="

  curl -sS "http://localhost:8080/api/tasks?limit=5" | python3 -m json.tool || true

  echo

  echo "===== GIT STATUS ====="

  git status --short

} | tee "$REPORT"

git add revert-uncommitted-task-response-enrichment.sh "$REPORT"

git commit -m "Revert uncommitted task response enrichment"

git push

