#!/bin/bash
set -e

echo "Cleaning Phase 565 marker text → production-safe empty states..."

sed -i '' 's/Phase 565 live tasks wire active — no recent tasks available./No recent tasks./g' public/js/phase565_recent_tasks_wire.js
sed -i '' 's/Phase 565 live logs wire active — no recent logs available./No recent logs./g' public/js/phase565_recent_logs_wire.js

node --check public/js/phase565_recent_tasks_wire.js
node --check public/js/phase565_recent_logs_wire.js

docker compose up -d --build dashboard

git add public/js/phase565_recent_tasks_wire.js public/js/phase565_recent_logs_wire.js
git commit -m "Phase 566: replace Phase 565 markers with production empty states"
git push
