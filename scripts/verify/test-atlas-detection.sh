#!/bin/bash
set -e

echo "Testing Atlas detection via subsystem endpoint..."

RESPONSE=$(curl -s http://localhost:8080/api/subsystem-status)

echo "$RESPONSE" | jq .

echo ""
echo "Checking Atlas field..."

if echo "$RESPONSE" | grep -q '"name":"atlas"'; then
  echo "Atlas field present"
else
  echo "Atlas field missing"
  exit 1
fi

echo ""
echo "Atlas detection test complete."
