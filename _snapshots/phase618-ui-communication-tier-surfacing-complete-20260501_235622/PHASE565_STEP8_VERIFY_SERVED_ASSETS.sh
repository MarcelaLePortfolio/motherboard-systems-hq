#!/bin/bash
set -e

echo "Checking local index includes..."
grep -n "phase565_recent_tasks_wire.js\|phase565_recent_logs_wire.js" public/index.html || true

echo ""
echo "Checking served index includes from localhost:3000..."
curl -s http://localhost:3000 | grep -n "phase565_recent_tasks_wire.js\|phase565_recent_logs_wire.js" || true

echo ""
echo "Checking served Recent Tasks JS marker..."
curl -s http://localhost:3000/js/phase565_recent_tasks_wire.js | grep -n "Phase 565 live tasks wire active\|data-phase565-recent-tasks-wire" || true

echo ""
echo "Checking dashboard container file presence..."
docker compose exec dashboard sh -lc 'ls -la /app/public/js | grep phase565 || true; grep -n "phase565_recent_tasks_wire.js\|phase565_recent_logs_wire.js" /app/public/index.html || true'

echo ""
echo "If served index/script does not show Phase 565, rebuild/restart dashboard container next."
