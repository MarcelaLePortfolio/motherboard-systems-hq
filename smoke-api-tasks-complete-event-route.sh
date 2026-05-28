
#!/usr/bin/env bash

set -euo pipefail

RUN_ID="route-smoke-$(date +%Y%m%d%H%M%S)"

TASK_ID="route-smoke-task-$(date +%s)"

echo "===== CREATE EVENT VIA /api/tasks ====="

curl -sS -X POST "http://localhost:8080/api/tasks" \

  -H "Content-Type: application/json" \

  --data "{\"task_id\":\"$TASK_ID\",\"run_id\":\"$RUN_ID\",\"title\":\"Route-level completion event smoke\",\"agent\":\"cade\",\"source\":\"route_event_smoke\"}" \

  | python3 -m json.tool

echo

echo "===== COMPLETE EVENT VIA /api/tasks/complete ====="

curl -sS -X POST "http://localhost:8080/api/tasks/complete" \

  -H "Content-Type: application/json" \

  --data "{\"task_id\":\"$TASK_ID\",\"run_id\":\"$RUN_ID\",\"status\":\"complete\",\"source\":\"route_event_smoke\"}" \

  | python3 -m json.tool

echo

echo "===== VERIFY EVENTS ====="

docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "select id, kind, task_id, run_id, actor, created_at from task_events where task_id='$TASK_ID' order by id asc;"

