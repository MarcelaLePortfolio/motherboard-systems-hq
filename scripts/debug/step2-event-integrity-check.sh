#!/bin/bash

echo "STEP 2 — EVENT STREAM INTEGRITY CHECK (SCHEMA-FIRST)"
echo "===================================================="

POSTGRES_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i postgres | head -n 1)

if [ -z "$POSTGRES_CONTAINER" ]; then
  echo "❌ No Postgres container found. Aborting."
  exit 1
fi

echo ""
echo "Inspecting task_events schema..."

docker exec -i "$POSTGRES_CONTAINER" psql -U postgres -d postgres -c "
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'task_events'
ORDER BY ordinal_position;
"

echo ""
echo "Inspecting recent task_events rows..."

docker exec -i "$POSTGRES_CONTAINER" psql -U postgres -d postgres -c "
SELECT *
FROM task_events
ORDER BY created_at DESC
LIMIT 20;
"

echo ""
echo "Paste output back into ChatGPT."
