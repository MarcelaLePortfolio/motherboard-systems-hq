#!/bin/bash
set -e

echo "Asserting required schema columns..."

RESULT=$(docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -t -c "
SELECT column_name
FROM information_schema.columns
WHERE table_name='tasks'
AND column_name IN ('next_run_at','completed_at');
")

echo "$RESULT"

if [[ "$RESULT" == *"next_run_at"* && "$RESULT" == *"completed_at"* ]]; then
  echo "Schema assertion PASSED"
else
  echo "Schema assertion FAILED"
  exit 1
fi
