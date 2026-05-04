#!/usr/bin/env bash
set -euo pipefail

echo "=== confirm task in DB ==="
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "
SELECT task_id, status, attempts, max_attempts
FROM tasks
ORDER BY updated_at DESC
LIMIT 5;
"

echo
echo "=== guidance endpoint ==="
curl -s http://localhost:3000/api/guidance | jq

echo
echo "=== guidance history ==="
curl -s http://localhost:3000/api/guidance-history | jq

echo
echo "=== dashboard logs (guidance-related) ==="
docker compose logs --tail=120 dashboard | grep -i guidance || true

echo
echo "=== done ==="
