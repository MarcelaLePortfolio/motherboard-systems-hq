#!/bin/bash
set -e

echo "Triggering test task via API..."

curl -s -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phase 568 telemetry validation task",
    "kind": "test",
    "payload": { "source": "phase568" }
  }' | jq '.' || curl -s -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Phase 568 telemetry validation task"}'

echo ""
echo "Now verify:"
echo "1. /api/tasks returns the task"
echo "2. Recent Tasks panel shows it"
echo "3. Logs panel updates (if SSE active)"
