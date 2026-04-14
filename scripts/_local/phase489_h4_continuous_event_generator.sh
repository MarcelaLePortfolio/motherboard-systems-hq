#!/usr/bin/env bash
set -euo pipefail

API="http://localhost:8080/api/tasks-mutations/delegate"

echo "Starting Phase 489 H4 continuous event generator..."
echo "Press Ctrl+C to stop."
echo

i=0
while true; do
  i=$((i+1))

  PAYLOAD=$(cat <<JSON
{
  "title": "H4 stream task #$i",
  "notes": "Continuous telemetry generation",
  "agent": "Cade",
  "source": "phase489-h4-generator"
}
JSON
)

  curl -s -X POST "$API" \
    -H "Content-Type: application/json" \
    --data "$PAYLOAD" > /dev/null

  echo "Emitted task #$i"

  sleep 2
done
