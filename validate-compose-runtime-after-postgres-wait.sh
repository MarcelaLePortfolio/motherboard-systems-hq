
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="COMPOSE_RUNTIME_AFTER_POSTGRES_WAIT_VALIDATION.txt"

BASE_URL="http://localhost:8080"

rm -f "$OUTPUT"

{

  echo "===== COMPOSE RUNTIME AFTER POSTGRES WAIT VALIDATION ====="

  date

  echo

  echo "===== WAIT FOR POSTGRES / DASHBOARD SETTLE ====="

  sleep 20

  echo "waited 20 seconds"

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== POSTGRES LOGS ====="

  docker logs --tail 80 motherboard-systems-hq-clean-postgres-1 || true

  echo

  echo "===== TASKS HEALTH ====="

  curl -i "${BASE_URL}/api/tasks/health" || true

  echo

  echo "===== DASHBOARD ROOT ====="

  curl -I "${BASE_URL}/" || true

  echo

  echo "===== GOVERNED ROUTE IN-PROCESS CONTROL ====="

  node server/execution/smoke-test-governed-route-inprocess.mjs

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add validate-compose-runtime-after-postgres-wait.sh COMPOSE_RUNTIME_AFTER_POSTGRES_WAIT_VALIDATION.txt

git commit -m "Validate compose runtime after Postgres wait" || true

git push

