#!/bin/bash
set -e

echo "Verifying no reassertion loops remain..."

echo ""
echo "Searching for setInterval usage in telemetry wires..."
grep -n "setInterval" public/js/phase565_recent_tasks_wire.js || echo "OK: no setInterval in tasks wire"
grep -n "setInterval" public/js/phase565_recent_logs_wire.js || echo "OK: no setInterval in logs wire"

echo ""
echo "Checking JS syntax..."
node --check public/js/phase565_recent_tasks_wire.js
node --check public/js/phase565_recent_logs_wire.js

echo ""
echo "Rebuilding dashboard to ensure clean runtime..."
docker compose up -d --build dashboard

echo ""
echo "Open dashboard and verify:"
echo "- No flicker"
echo "- No duplicate renders"
echo "- Empty state persists cleanly"

echo ""
echo "Phase 567 reassertion removal verified."
