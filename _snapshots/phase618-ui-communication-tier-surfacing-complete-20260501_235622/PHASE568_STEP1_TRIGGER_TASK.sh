#!/bin/bash
set -e

echo "Triggering Phase 568 validation task via active route: POST /api/tasks/create"

curl -s -X POST http://localhost:3000/api/tasks/create \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phase 568 telemetry validation task",
    "status": "queued",
    "agent": "cade",
    "source": "phase568"
  }' | jq '.'

echo ""
echo "Reading /api/tasks after creation..."
curl -s http://localhost:3000/api/tasks | jq '.'
