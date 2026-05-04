#!/bin/bash
set -e

echo "PHASE 639 — GUIDANCE + SUBSYSTEM VALIDATION START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Call /api/guidance"
RESPONSE=$(curl -s http://localhost:8080/api/guidance)

echo "$RESPONSE" | jq .

echo ""
echo "Step 4: Validate subsystem presence in guidance response..."

if echo "$RESPONSE" | grep -q '"subsystems"'; then
  echo "Subsystem data present in guidance response"
else
  echo "Subsystem data missing in guidance response"
  exit 1
fi

echo ""
echo "PHASE 639 — VALIDATION COMPLETE"
