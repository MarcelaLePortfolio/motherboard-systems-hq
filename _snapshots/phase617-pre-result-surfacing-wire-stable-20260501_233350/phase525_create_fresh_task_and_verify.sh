#!/usr/bin/env bash
set -euo pipefail

echo "[1] Create fresh delegated task"
curl -sS -X POST 'http://localhost:8080/api/delegate-task' \
  -H 'content-type: application/json' \
  -d '{"title":"Phase 525 completion verification","prompt":"Phase 525 completion verification","agent":"cade"}' | jq

echo
echo "[2] Wait for worker to process"
sleep 8

echo
echo "[3] Fetch latest task state"
curl -sS 'http://localhost:8080/api/tasks?limit=3' | jq

echo
echo "[4] Fetch recent task events"
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c \
  "select kind, task_id, actor, created_at from task_events order by created_at desc limit 10;"

git add phase525_create_fresh_task_and_verify.sh
git commit -m "Phase 525: add fresh delegated task verification script"
git push
