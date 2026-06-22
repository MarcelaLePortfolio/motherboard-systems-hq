
#!/usr/bin/env bash

set -euo pipefail

REPORT="CRITICAL_RECOVERY_CORRIDORS_INSPECTION.txt"

{

  echo "===== CRITICAL RECOVERY CORRIDORS INSPECTION ====="

  date

  echo

  echo "===== GIT STATE ====="

  git branch --show-current

  git log --oneline -12

  git status --short

  echo

  echo "===== DOCKER STATE ====="

  docker compose ps

  echo

  echo "===== DASHBOARD HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health || true

  echo

  curl -I http://localhost:8080/ || true

  echo

  echo "===== GOVERNED EXECUTION SMOKES ====="

  node server/execution/smoke-test-envelope-draft.mjs

  node server/execution/smoke-test-approval-gate.mjs

  node server/execution/smoke-test-governed-planning-pipeline.mjs

  node server/execution/smoke-test-governed-route-inprocess.mjs

  node server/execution/smoke-test-governed-route-fail-closed.mjs

  echo

  echo "===== LIVE GOVERNED ROUTE ====="

  curl -sS -X POST http://localhost:8080/api/governed-planning/dry-run \

    -H 'Content-Type: application/json' \

    --data @server/execution/smoke-test-governed-route-payload.json | python3 -m json.tool || true

  echo

  echo "===== TASKS API ====="

  curl -sS 'http://localhost:8080/api/tasks?limit=12' | python3 -m json.tool || true

  echo

  echo "===== SSE / EVENTS ROUTES ====="

  curl -I http://localhost:8080/events/ops || true

  curl -I http://localhost:8080/events/reflections || true

  curl -I http://localhost:8080/events/task-events || true

  echo

  echo "===== ORCHESTRATOR ROUTE ====="

  curl -sS http://localhost:8080/orchestrator/state._debug | python3 -m json.tool || true

  echo

  echo "===== DATABASE TABLES ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d motherboard -c "\dt" || true

  echo

  echo "===== TASK TABLE SHAPE ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d motherboard -c "\d tasks" || true

  echo

  echo "===== WORKER FILES PRESENT ====="

  ls -la server/worker/phase26_task_worker.mjs server/task_events_emit.mjs server/routes/api-tasks-postgres.mjs server/routes/governed-planning-route.mjs

  echo

  echo "===== RECENT DASHBOARD LOGS ====="

  docker logs --tail 180 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== CONCLUSION TEMPLATE ====="

  echo "If governed smokes pass, live governed route returns ok:true, task health is 200, DB tables are present, and dashboard logs show no route crashes, the critical backend corridors are restored enough to stop broad inspection."

} | tee "$REPORT"

git add inspect-critical-recovery-corridors.sh "$REPORT"

git commit -m "Inspect critical recovery corridors"

git push

