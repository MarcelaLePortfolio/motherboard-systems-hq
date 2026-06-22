
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="GOVERNED_ROUTE_AFTER_RUNTIME_RESTORE_SMOKE.txt"

URL="http://localhost:8080/api/governed-planning/dry-run"

rm -f "$OUTPUT"

{

  echo "===== GOVERNED ROUTE AFTER RUNTIME RESTORE SMOKE ====="

  date

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== BASELINE HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== GOVERNED ROUTE HTTP RESPONSE ====="

  curl -sS -i -X POST "$URL" \

    -H "Content-Type: application/json" \

    --data @server/execution/smoke-test-governed-route-payload.json

  echo

  echo "===== IN-PROCESS CONTROL ====="

  node server/execution/smoke-test-governed-route-inprocess.mjs

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add smoke-governed-route-after-runtime-restore.sh GOVERNED_ROUTE_AFTER_RUNTIME_RESTORE_SMOKE.txt

git commit -m "Smoke governed route after runtime restore" || true

git push

