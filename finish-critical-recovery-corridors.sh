
#!/usr/bin/env bash

set -euo pipefail

REPORT="CRITICAL_RECOVERY_CORRIDORS_FINISH.txt"

{

  echo "===== FINISH CRITICAL RECOVERY CORRIDORS ====="

  date

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

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== CONCLUSION ====="

  echo "Governed execution already passed. If these remaining checks are healthy, broad backend inspection can stop."

} | tee "$REPORT"

git add finish-critical-recovery-corridors.sh "$REPORT"

git commit -m "Finish critical recovery corridor inspection"

git push

