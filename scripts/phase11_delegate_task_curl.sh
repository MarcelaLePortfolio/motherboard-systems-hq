#!/usr/bin/env bash
set -euo pipefail

# Phase 11 – Helper script to run the delegate-task curl against the container backend
# and show recent logs for quick inspection.

# Always run from repo root
cd "$(dirname "$0")/.."

echo "🔹 Running delegate-task curl against http://127.0.0.1:3000/api/delegate-task ..."
echo

curl -i -X POST http://127.0.0.1:3000/api/delegate-task \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phase 11 container curl test",
    "agent": "cade",
    "notes": "Created via Phase 11 backend validation"
  }'

echo
echo "🔹 Showing recent docker-compose logs (last 50 lines)..."
echo

docker-compose logs --tail=50

echo
echo "✅ phase11_delegate_task_curl.sh run complete. Review HTTP status, response body, and logs above."
