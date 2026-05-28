
#!/usr/bin/env bash

set -euo pipefail

echo "===== DIRECT dbCompleteTask SMOKE INSIDE DASHBOARD CONTAINER ====="

docker exec motherboard-systems-hq-clean-dashboard-1 node /app/smoke-db-complete-task-direct.mjs

