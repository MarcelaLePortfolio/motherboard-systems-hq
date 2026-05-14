
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REBUILD DASHBOARD AFTER ROUTE RESTORE ====="

mkdir -p checkpoints

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "LOCAL ROUTE WIRING BEFORE REBUILD"

  grep -nE 'apiTasksRouter|app.use\("/api/tasks"|express.static|Dashboard is running|/api/artifacts' server.js server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "REBUILD DASHBOARD IMAGE"

  docker compose up -d --build dashboard

  echo ""

  echo "WAIT FOR DASHBOARD"

  sleep 5

  echo ""

  echo "CONTAINER SERVER ROUTE WIRING AFTER REBUILD"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'grep -nE "apiTasksRouter|app.use\\(\"/api/tasks\"|express.static|Dashboard is running|/api/artifacts" /app/server.js /app/server/routes/api-tasks-postgres.mjs || true' || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "ROOT ROUTE"

  curl -i -s --max-time 10 http://localhost:3000/ || true

  echo ""

  echo "TASK API HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "TASK API LIST"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks || true

  echo ""

  echo "ARTIFACT TEST ROUTE"

  curl -i -s --max-time 10 http://localhost:3000/api/artifacts/test || true

  echo ""

  echo "STATUS"

  git status --short

} | tee checkpoints/PHASE719_DASHBOARD_REBUILD_AFTER_ROUTE_RESTORE.txt

git add PHASE719_REBUILD_DASHBOARD_AFTER_ROUTE_RESTORE.sh checkpoints/PHASE719_DASHBOARD_REBUILD_AFTER_ROUTE_RESTORE.txt

git commit -m "Phase 719: rebuild dashboard after route restore"

git push origin "$(git branch --show-current)"

echo "===== REBUILD VERIFY COMPLETE ====="

