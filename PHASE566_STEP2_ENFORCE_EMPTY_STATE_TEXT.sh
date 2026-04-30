#!/bin/bash
set -e

echo "Enforcing consistent empty-state text in Phase 565 UI wires..."

sed -i '' 's/No recent tasks\./No recent tasks yet./g' public/js/phase565_recent_tasks_wire.js
sed -i '' 's/No recent logs\./No task history yet./g' public/js/phase565_recent_logs_wire.js

node --check public/js/phase565_recent_tasks_wire.js
node --check public/js/phase565_recent_logs_wire.js

docker compose up -d --build dashboard

git add public/js/phase565_recent_tasks_wire.js public/js/phase565_recent_logs_wire.js
git commit -m "Phase 566: enforce consistent empty-state text across telemetry panels"
git push
