
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_PAYLOAD_SHAPE_GAP_INSPECTION.txt"

{

  echo "===== TASK PAYLOAD SHAPE GAP INSPECTION ====="

  date

  echo

  echo "===== ACTIVE /api/tasks HANDLER IN server.mjs ====="

  sed -n '340,375p' server.mjs

  echo

  echo "===== ROUTER /api/tasks HANDLER IN server/routes/api-tasks-postgres.mjs ====="

  sed -n '38,70p' server/routes/api-tasks-postgres.mjs

  echo

  echo "===== CARD RENDERER EXPECTED TASK FIELDS ====="

  sed -n '80,235p' public/js/phase530_visible_panels_bridge.js

  echo

  echo "===== LIVE TASKS FULL DB ROWS ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "select id, task_id, title, status, notes, run_id, action_tier, kind, payload, metadata, description, assignee, created_at, updated_at from tasks order by id desc limit 8;"

  echo

  echo "===== LIVE /api/tasks RESPONSE ====="

  curl -sS "http://localhost:8080/api/tasks?limit=8" | python3 -m json.tool || true

} | tee "$REPORT"

git add inspect-task-payload-shape-gap.sh "$REPORT"

git commit -m "Inspect task payload shape gap"

git push

