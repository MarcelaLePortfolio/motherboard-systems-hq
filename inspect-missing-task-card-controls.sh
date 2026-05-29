
#!/usr/bin/env bash

set -euo pipefail

REPORT="MISSING_TASK_CARD_CONTROLS_INSPECTION.txt"

{

  echo "===== MISSING TASK CARD CONTROLS INSPECTION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== CARD RENDER CONDITIONALS ====="

  grep -nE "artifactRaw|triageLabel|traceJson|explanation_preview|outcome_preview|Inspect trace|Inspect logs|Preview|triage" public/js/phase530_visible_panels_bridge.js | head -120

  echo

  echo "===== RENDERER CONTEXT ====="

  sed -n '120,235p' public/js/phase530_visible_panels_bridge.js

  echo

  echo "===== CURRENT /api/tasks SHAPE ====="

  curl -sS "http://localhost:8080/api/tasks?limit=8" | python3 -m json.tool

  echo

  echo "===== DB TASK PAYLOAD / METADATA SHAPE ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "

select

  id,

  task_id,

  title,

  status,

  kind,

  payload,

  metadata

from tasks

order by id desc

limit 12;

"

  echo

  echo "===== TASK EVENTS PAYLOAD SHAPE ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "

select

  id,

  kind,

  task_id,

  run_id,

  payload

from task_events

order by id desc

limit 12;

"

} | tee "$REPORT"

git add inspect-missing-task-card-controls.sh "$REPORT"

git commit -m "Inspect missing task card controls"

git push

