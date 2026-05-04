#!/usr/bin/env bash
set -euo pipefail

RETRY_ID="retry_test_failure_$(date +%s)"

echo "=== create retry task ==="
curl -sS -X POST http://localhost:3000/api/tasks/create \
  -H 'Content-Type: application/json' \
  -d "{
    \"task_id\": \"$RETRY_ID\",
    \"title\": \"Retry test-failure\",
    \"status\": \"queued\",
    \"kind\": \"retry\",
    \"payload\": {
      \"retry_of_task_id\": \"test-failure\",
      \"execution_mode\": \"rebuild_context\",
      \"cache_policy\": \"bypass\",
      \"memory_scope\": \"reset_partial\",
      \"strategy\": \"fresh-context\"
    },
    \"source\": \"phase674-controlled-probe\"
  }" | jq

echo
echo "=== verify retry task row ==="
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "
SELECT task_id, status, kind, payload
FROM tasks
WHERE task_id = '$RETRY_ID';
"

echo
echo "=== guidance after retry probe ==="
curl -sS http://localhost:3000/api/guidance | jq

echo
echo "=== git status ==="
git status --short
