
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT ROUTE SYNTAX MISMATCH ====="

mkdir -p checkpoints

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "LOCAL ROUTER SYNTAX CHECK"

  node --check server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "LOCAL ROUTER LINES 260-340"

  nl -ba server/routes/api-tasks-postgres.mjs | sed -n '260,340p' || true

  echo ""

  echo "CONTAINER STATUS"

  docker ps -a | grep motherboard_systems_hq-dashboard || true

  echo ""

  echo "CONTAINER ROUTER LINES 260-340"

  docker cp motherboard_systems_hq-dashboard-1:/app/server/routes/api-tasks-postgres.mjs /tmp/phase719_container_api_tasks_postgres.mjs 2>/dev/null || true

  if [ -f /tmp/phase719_container_api_tasks_postgres.mjs ]; then

    nl -ba /tmp/phase719_container_api_tasks_postgres.mjs | sed -n '260,340p' || true

    echo ""

    echo "CONTAINER ROUTER SYNTAX CHECK VIA NODE"

    docker run --rm -v /tmp/phase719_container_api_tasks_postgres.mjs:/tmp/api-tasks-postgres.mjs node:20-alpine node --check /tmp/api-tasks-postgres.mjs || true

  else

    echo "Could not copy container route file."

  fi

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_ROUTE_SYNTAX_MISMATCH_INSPECTION.txt

git add PHASE719_INSPECT_ROUTE_SYNTAX_MISMATCH.sh checkpoints/PHASE719_ROUTE_SYNTAX_MISMATCH_INSPECTION.txt checkpoints/PHASE719_BROKEN_ARTIFACT_ENDPOINT_EXCERPT.txt

git commit -m "Phase 719: inspect route syntax mismatch"

git push origin "$(git branch --show-current)"

echo "===== ROUTE SYNTAX MISMATCH INSPECTION COMPLETE ====="

