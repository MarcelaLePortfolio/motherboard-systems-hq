#!/bin/bash
set -e

echo "Checking status..."
git status --short

echo ""
echo "Checking JS syntax..."
node --check public/js/phase565_recent_tasks_wire.js
node --check public/js/phase565_recent_logs_wire.js

echo ""
echo "Checking containers..."
docker compose ps

echo ""
echo "Tagging Phase 566 telemetry UI polished..."
git tag phase566-telemetry-ui-polished
git push origin phase566-telemetry-ui-polished
