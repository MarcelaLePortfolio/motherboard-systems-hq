
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_ITEM_UI_WIRING_INSPECTION.txt"

{

  echo "===== TASK ITEM UI WIRING INSPECTION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== TASK API SNAPSHOT ====="

  curl -sS "http://localhost:8080/api/tasks?limit=12" | python3 -m json.tool || true

  echo

  echo "===== TASK EVENTS SNAPSHOT ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "select id, kind, task_id, run_id, actor, created_at from task_events order by id desc limit 12;" || true

  echo

  echo "===== FRONTEND TASK ACTION WIRING SEARCH ====="

  grep -RniE "data-task|complete|retry|inspect|trace|json|task_id|taskId|recentTasks|renderRecent|phase717|phase719" public/index.html public/dashboard.html public/js/phase530_visible_panels_bridge.js | head -260 || true

  echo

  echo "===== BACKEND TASK MUTATION ROUTES ====="

  sed -n '1,130p' server/routes/api-tasks-mutations.mjs

  echo

  sed -n '220,285p' server/tasks-mutations.mjs

  echo

  echo "===== MOUNTED ROUTE DISCOVERY ====="

  grep -RniE "api-tasks-mutations|tasks-mutations|delegate-taskspec|api/tasks" server.mjs server/routes 2>/dev/null | head -180 || true

} | tee "$REPORT"

git add inspect-task-item-ui-wiring.sh "$REPORT"

git commit -m "Inspect task item UI wiring"

git push

