
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_RESPONSE_ENRICHMENT_CRASH_RECOVERY.txt"

{

  echo "===== TASK RESPONSE ENRICHMENT CRASH RECOVERY ====="

  date

  echo

  echo "===== STATUS ====="

  git status --short

  echo

  echo "===== CURRENT DIFF ====="

  git diff -- server/routes/api-tasks-postgres.mjs || true

  echo

  echo "===== DOCKER STATE ====="

  docker compose ps || true

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 220 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== HEALTH CHECK ====="

  curl -i http://localhost:8080/api/tasks/health || true

} | tee "$REPORT"

if ! curl -fsS http://localhost:8080/api/tasks/health >/dev/null 2>&1; then

  echo "===== HEALTH FAILED: REVERTING TASK RESPONSE ENRICHMENT PATCH =====" | tee -a "$REPORT"

  git checkout -- server/routes/api-tasks-postgres.mjs

  docker compose build dashboard

  docker compose up -d dashboard

  sleep 2

  curl -i http://localhost:8080/api/tasks/health | tee -a "$REPORT" || true

fi

git add "$REPORT" recover-task-response-enrichment-crash.sh

git commit -m "Recover from task response enrichment crash"

git push

