#!/usr/bin/env bash
set -euo pipefail

# Phase 11 – Helper script to run the complete-task curl against the container backend
# and then show recent logs for quick inspection.
#
# Usage:
#   scripts/phase11_complete_task_curl.sh TASK_ID
#
# Example:
#   scripts/phase11_complete_task_curl.sh 42

if [[ $# -lt 1 ]]; then
  echo "❌ Usage: $0 TASK_ID"
  exit 1
fi

TASK_ID="$1"

# Always run from repo root
cd "$(dirname "$0")/.."

echo "🔹 Running complete-task curl against http://127.0.0.1:3000/api/complete-task ..."
echo "   Using taskId=${TASK_ID}"
echo

curl -i -X POST http://127.0.0.1:3000/api/complete-task \
  -H "Content-Type: application/json" \
  -d "{\"taskId\": ${TASK_ID}}"

echo
echo "🔹 Showing recent docker-compose logs (last 50 lines)..."
echo

docker-compose logs --tail=50

echo
echo "✅ phase11_complete_task_curl.sh run complete. Review HTTP status, response body, and logs above."
