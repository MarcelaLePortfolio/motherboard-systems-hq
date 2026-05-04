#!/bin/bash
set -e

echo "PHASE 650 — GUIDANCE INTELLIGENCE VALIDATION START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Call /api/guidance"
RESPONSE=$(curl -s http://localhost:8080/api/guidance)

echo "$RESPONSE" | jq .

echo ""
echo "Step 4: Validate guidance presence..."

if echo "$RESPONSE" | grep -q '"guidance"'; then
  echo "Guidance field present"
else
  echo "Guidance field missing"
  exit 1
fi

echo ""
echo "Step 5: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo ""
echo "Manual check:"
echo "- Guidance panel shows messages (info or warning)"
echo "- Updates every ~5 seconds"
echo "- Matches subsystem state"

echo ""
echo "PHASE 650 — VALIDATION COMPLETE"
