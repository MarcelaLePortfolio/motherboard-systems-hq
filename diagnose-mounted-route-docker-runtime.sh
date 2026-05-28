
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="GOVERNED_ROUTE_DOCKER_RUNTIME_DIAGNOSIS.txt"

PORT="${PORT:-3000}"

URL="http://localhost:${PORT}/api/governed-planning/dry-run"

rm -f "$OUTPUT"

echo "===== GOVERNED ROUTE DOCKER RUNTIME DIAGNOSIS =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER PS =====" | tee -a "$OUTPUT"

docker ps | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== PORT OWNER =====" | tee -a "$OUTPUT"

lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

CONTAINER_ID="$(docker ps --format '{{.ID}}' | head -1 || true)"

echo "" | tee -a "$OUTPUT"

echo "===== SELECTED CONTAINER =====" | tee -a "$OUTPUT"

echo "${CONTAINER_ID:-NONE}" | tee -a "$OUTPUT"

if [ -n "$CONTAINER_ID" ]; then

  echo "" | tee -a "$OUTPUT"

  echo "===== CONTAINER LOGS BEFORE REQUEST =====" | tee -a "$OUTPUT"

  docker logs --tail 120 "$CONTAINER_ID" 2>&1 | tee -a "$OUTPUT" || true

fi

echo "" | tee -a "$OUTPUT"

echo "===== HTTP REQUEST =====" | tee -a "$OUTPUT"

curl -v -X POST "$URL" -H "Content-Type: application/json" --data @server/execution/smoke-test-governed-route-payload.json 2>&1 | tee -a "$OUTPUT" || true

if [ -n "$CONTAINER_ID" ]; then

  echo "" | tee -a "$OUTPUT"

  echo "===== CONTAINER LOGS AFTER REQUEST =====" | tee -a "$OUTPUT"

  docker logs --tail 180 "$CONTAINER_ID" 2>&1 | tee -a "$OUTPUT" || true

  echo "" | tee -a "$OUTPUT"

  echo "===== CONTAINER SERVER MOUNT CHECK =====" | tee -a "$OUTPUT"

  docker exec "$CONTAINER_ID" sh -lc 'grep -n "governedPlanningRouter\|governed-planning-route\|api/tasks-mutations" /app/server.mjs 2>/dev/null || grep -n "governedPlanningRouter\|governed-planning-route\|api/tasks-mutations" server.mjs 2>/dev/null || true' 2>&1 | tee -a "$OUTPUT" || true

  echo "" | tee -a "$OUTPUT"

  echo "===== CONTAINER ROUTE FILE CHECK =====" | tee -a "$OUTPUT"

  docker exec "$CONTAINER_ID" sh -lc 'ls -lh /app/server/routes/governed-planning-route.mjs 2>/dev/null || ls -lh server/routes/governed-planning-route.mjs 2>/dev/null || true' 2>&1 | tee -a "$OUTPUT" || true

fi

echo "" | tee -a "$OUTPUT"

echo "===== LOCAL STATIC CHECKS =====" | tee -a "$OUTPUT"

node --check server/routes/governed-planning-route.mjs 2>&1 | tee -a "$OUTPUT"

node server/execution/smoke-test-governed-route.mjs 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add diagnose-mounted-route-docker-runtime.sh GOVERNED_ROUTE_DOCKER_RUNTIME_DIAGNOSIS.txt

git commit -m "Diagnose governed route Docker runtime reset" || true

git push

