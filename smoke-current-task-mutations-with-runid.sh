
#!/usr/bin/env bash

set -euo pipefail

RUN_ID="resume-smoke-$(date +%Y%m%d%H%M%S)"

echo "===== SMOKE TASK MUTATIONS WITH RUN_ID ====="

echo "RUN_ID=$RUN_ID"

TASK_JSON=$(curl -sS -X POST "http://localhost:8080/api/tasks-mutations/delegate" -H "Content-Type: application/json" --data "{\"title\":\"Governed execution resume smoke task with run_id\",\"agent\":\"cade\",\"notes\":\"Smoke test with run_id after schema migration\",\"source\":\"resume_validation\",\"run_id\":\"$RUN_ID\"}")

printf '%s\n' "$TASK_JSON" | python3 -m json.tool

TASK_ID=$(printf '%s' "$TASK_JSON" | python3 -c 'import sys,json; d=json.load(sys.stdin); print((d.get("task") or {}).get("task_id",""))')

echo

echo "TASK_ID=$TASK_ID"

echo

echo "===== COMPLETE SMOKE TASK WITH RUN_ID ====="

curl -sS -X POST "http://localhost:8080/api/tasks-mutations/complete" -H "Content-Type: application/json" --data "{\"task_id\":\"$TASK_ID\",\"run_id\":\"$RUN_ID\",\"summary\":\"Completed mutation endpoint smoke with run_id after recovery\"}" | python3 -m json.tool

echo

echo "===== VERIFY TASKS API ====="

curl -sS "http://localhost:8080/api/tasks?limit=5" | python3 -m json.tool

echo

echo "===== VERIFY TASK EVENTS ====="

docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "select id, kind, task_id, run_id, actor, created_at from task_events order by id desc limit 8;"

