
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VERIFY RESTORED TASK API ACTIVE ====="

mkdir -p checkpoints

echo "[1] Wait briefly after dashboard restart"

sleep 3

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "HEAD"

  git log --oneline --decorate -5

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "ROUTE WIRING IN LOCAL FILES"

  grep -nE 'apiTasksRouter|app.use\("/api/tasks"|express.static|/api/artifacts|Dashboard is running' server.js server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "DOCKER CONTAINERS"

  docker ps

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

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

} | tee checkpoints/PHASE719_RESTORED_TASK_API_ACTIVE_VERIFY.txt

git add PHASE719_VERIFY_RESTORED_TASK_API_ACTIVE.sh checkpoints/PHASE719_RESTORED_TASK_API_ACTIVE_VERIFY.txt

git commit -m "Phase 719: verify restored task API runtime activation"

git push origin phase719-artifact-visibility-ui

echo "===== VERIFY COMPLETE ====="

