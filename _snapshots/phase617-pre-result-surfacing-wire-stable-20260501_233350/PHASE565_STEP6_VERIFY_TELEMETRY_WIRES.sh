#!/bin/bash
set -e

echo "Checking script includes..."
grep -n "phase565_recent_tasks_wire.js\|phase565_recent_logs_wire.js" public/index.html

echo ""
echo "Checking JS syntax..."
node --check public/js/phase565_recent_tasks_wire.js
node --check public/js/phase565_recent_logs_wire.js

echo ""
echo "Checking API endpoints..."
curl -s http://localhost:3000/api/tasks
echo ""
curl -s -I http://localhost:3000/events/tasks | head

echo ""
echo "Phase 565 telemetry wires verified."
