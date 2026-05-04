#!/bin/bash
set -e

echo "ATLAS DETECTION TEST START"

echo "Step 1: Check current state"
docker ps | grep atlas || echo "atlas not running"

echo ""
echo "Step 2: (Optional) Start Atlas if you have a container definition"
echo "Skipping auto-start to avoid unsafe assumptions"

echo ""
echo "Step 3: Rebuild system to refresh detection"
docker compose up -d --build
sleep 5

echo ""
echo "Step 4: Check API response"
curl -s http://localhost:8080/api/guidance | jq '.subsystems'

echo ""
echo "Expected:"
echo "- atlas shows connected: false when not running"
echo "- switches to connected: true when container exists"

echo ""
echo "ATLAS DETECTION TEST COMPLETE"
