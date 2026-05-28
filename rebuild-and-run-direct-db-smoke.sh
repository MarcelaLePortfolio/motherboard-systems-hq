
#!/usr/bin/env bash

set -euo pipefail

docker compose build dashboard

docker compose up -d dashboard

echo "===== VERIFY SMOKE FILE EXISTS IN CONTAINER ====="

docker exec motherboard-systems-hq-clean-dashboard-1 ls -la /app/smoke-db-complete-task-direct.mjs

echo

echo "===== RUN DIRECT DB COMPLETE TASK SMOKE ====="

docker exec motherboard-systems-hq-clean-dashboard-1 node /app/smoke-db-complete-task-direct.mjs

