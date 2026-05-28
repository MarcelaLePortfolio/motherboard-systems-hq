
#!/usr/bin/env bash

set -euo pipefail

echo "===== SMOKE CURRENT TASK MUTATION ENDPOINTS ====="

TASK_JSON=$(curl -sS -X POST "http://localhost:8080/api/tasks-mutations/delegate" -H "Content-Type: application/json" --data '{"title":"Governed execution resume smoke task","agent":"cade","notes":"Smoke test after Docker reset recovery","source":"resume_validation"}')

printf '%s\n' "$TASK_JSON" | python3 -m json.tool

TASK_ID=$(printf '%s' "$TASK_JSON" | python3 -c 'import sys,json; d=json.load(sys.stdin); print((d.get("task") or {}).get("task_id",""))')

echo

echo "TASK_ID=$TASK_ID"

echo

echo "===== COMPLETE SMOKE TASK ====="

curl -sS -X POST "http://localhost:8080/api/tasks-mutations/complete" -H "Content-Type: application/json" --data "{\"task_id\":\"$TASK_ID\",\"summary\":\"Completed mutation endpoint smoke after recovery\"}" | python3 -m json.tool

echo

echo "===== VERIFY TASKS API ====="

curl -sS "http://localhost:8080/api/tasks?limit=5" | python3 -m json.tool

