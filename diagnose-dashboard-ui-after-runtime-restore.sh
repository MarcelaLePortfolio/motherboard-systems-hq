
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="DASHBOARD_UI_AFTER_RUNTIME_RESTORE_DIAGNOSIS.txt"

BASE_URL="http://localhost:8080"

rm -f "$OUTPUT"

{

  echo "===== DASHBOARD UI AFTER RUNTIME RESTORE DIAGNOSIS ====="

  date

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== DASHBOARD ROOT STATUS ====="

  curl -i "$BASE_URL/" | head -80 || true

  echo

  echo "===== DASHBOARD HTML ASSET REFERENCES ====="

  curl -sS "$BASE_URL/" | grep -Eo 'src="[^"]+"|href="[^"]+"' | head -120 || true

  echo

  echo "===== KEY API ROUTES ====="

  for path in \

    /api/tasks/health \

    /api/tasks?limit=12 \

    /events/task-events \

    /events/artifacts \

    /agent-status.json

  do

    echo

    echo "----- $path -----"

    curl -i --max-time 5 "$BASE_URL$path" | head -120 || true

  done

  echo

  echo "===== PUBLIC DASHBOARD FILES IN CONTAINER ====="

  docker exec motherboard-systems-hq-clean-dashboard-1 sh -lc 'find /app/public -maxdepth 3 -type f | sort | head -200' || true

  echo

  echo "===== SERVER ROUTE MOUNTS ====="

  docker exec motherboard-systems-hq-clean-dashboard-1 sh -lc 'grep -n "app.use\|app.get\|app.post\|events/task-events\|api/tasks\|agent-status" /app/server.mjs | head -220' || true

  echo

  echo "===== RECENT DASHBOARD LOGS ====="

  docker logs --tail 200 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== POSTGRES TABLES ====="

  docker compose exec -T postgres psql -U postgres -d postgres -c '\dt' || true

  echo

  echo "===== TASK COUNTS ====="

  docker compose exec -T postgres psql -U postgres -d postgres -c 'select count(*) as tasks_count from tasks;' || true

  docker compose exec -T postgres psql -U postgres -d postgres -c 'select count(*) as task_events_count from task_events;' || true

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add diagnose-dashboard-ui-after-runtime-restore.sh DASHBOARD_UI_AFTER_RUNTIME_RESTORE_DIAGNOSIS.txt

git commit -m "Diagnose dashboard UI after runtime restore" || true

git push

