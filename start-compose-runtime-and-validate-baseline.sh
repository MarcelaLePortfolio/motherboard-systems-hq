
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="COMPOSE_RUNTIME_BASELINE_VALIDATION.txt"

BASE_URL="${BASE_URL:-http://localhost:8080}"

rm -f "$OUTPUT"

echo "===== COMPOSE RUNTIME BASELINE VALIDATION =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== START DASHBOARD STACK =====" | tee -a "$OUTPUT"

docker compose up -d postgres dashboard 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE PS =====" | tee -a "$OUTPUT"

docker compose ps 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== PORT OWNERS =====" | tee -a "$OUTPUT"

lsof -nP -iTCP:8080 -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

lsof -nP -iTCP:3000 -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DASHBOARD LOGS =====" | tee -a "$OUTPUT"

docker compose logs --tail=120 dashboard 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== BASELINE HEALTH =====" | tee -a "$OUTPUT"

curl -i "${BASE_URL}/api/health" 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== TASKS HEALTH =====" | tee -a "$OUTPUT"

curl -i "${BASE_URL}/api/tasks/health" 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DASHBOARD ROOT HEAD =====" | tee -a "$OUTPUT"

curl -I "${BASE_URL}/" 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== GOVERNED ROUTE STILL VALIDATED IN-PROCESS =====" | tee -a "$OUTPUT"

node server/execution/smoke-test-governed-route-inprocess.mjs 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add start-compose-runtime-and-validate-baseline.sh COMPOSE_RUNTIME_BASELINE_VALIDATION.txt

git commit -m "Start compose runtime and validate baseline" || true

git push

