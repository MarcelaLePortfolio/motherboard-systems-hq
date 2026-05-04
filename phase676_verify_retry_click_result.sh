#!/usr/bin/env bash
set -euo pipefail

echo "=== recent retry tasks ==="
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "
SELECT task_id, status, kind, payload, created_at
FROM tasks
WHERE kind = 'retry'
ORDER BY created_at DESC
LIMIT 10;
"

echo
echo "=== guidance ==="
curl -sS http://localhost:3000/api/guidance | jq

echo
echo "=== git status ==="
git status --short
