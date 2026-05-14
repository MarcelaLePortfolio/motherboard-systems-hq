
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT DOCKER SOURCE MAPPING ====="

mkdir -p checkpoints

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "LOCAL SERVER ROUTE WIRING"

  grep -nE 'apiTasksRouter|app.use\("/api/tasks"|express.static|Dashboard is running' server.js || true

  echo ""

  echo "DOCKER COMPOSE CONFIG"

  docker compose config || true

  echo ""

  echo "CONTAINER WORKDIR FILE LIST"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'pwd; ls -la /app | head -80' || true

  echo ""

  echo "CONTAINER SERVER ROUTE WIRING"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'grep -nE "apiTasksRouter|app.use\\(\"/api/tasks\"|express.static|Dashboard is running" /app/server.js || true' || true

  echo ""

  echo "CONTAINER SERVER HEAD"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'head -n 90 /app/server.js' || true

  echo ""

  echo "CONTAINER PACKAGE START"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'cat /app/package.json | grep -nE "type|scripts|start|dev|server" -A 12 -B 4 || true' || true

  echo ""

  echo "LIVE ROUTES"

  curl -i -s --max-time 10 http://localhost:3000/ || true

  echo ""

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  curl -i -s --max-time 10 http://localhost:3000/api/tasks || true

  echo ""

} | tee checkpoints/PHASE719_DOCKER_SOURCE_MAPPING_INSPECTION.txt

git add PHASE719_INSPECT_DOCKER_SOURCE_MAPPING.sh checkpoints/PHASE719_DOCKER_SOURCE_MAPPING_INSPECTION.txt

git commit -m "Phase 719: inspect Docker source mapping for task API recovery"

git push origin phase719-artifact-visibility-ui

echo "===== SOURCE MAPPING INSPECTION COMPLETE ====="

