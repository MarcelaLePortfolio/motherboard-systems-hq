#!/bin/bash

echo "STEP 3 — DASHBOARD SOURCE CHECK"
echo "================================"

echo ""
echo "1. Checking server routes for dashboard serving..."
grep -R "dashboard_phase6.8" -n dist routes . 2>/dev/null | head -20

echo ""
echo "2. Checking for static file serving paths..."
grep -R "express.static" -n dist . 2>/dev/null | head -20

echo ""
echo "3. Checking for any dashboard.html references..."
grep -R "dashboard.html" -n dist . 2>/dev/null | head -20

echo ""
echo "4. Checking container logs for served paths..."
APP_CONTAINER=$(docker ps --format '{{.Names}}' | grep -Ei 'app|server|motherboard' | head -n 1)
if [ -n "$APP_CONTAINER" ]; then
  docker logs --tail 50 "$APP_CONTAINER" 2>&1 | grep -i "dashboard\|static\|serv" | tail -20
else
  echo "⚠️ No app container found"
fi

echo ""
echo "RESULT:"
echo "We are identifying which dashboard file is actually being served."
echo "Paste output into ChatGPT."
