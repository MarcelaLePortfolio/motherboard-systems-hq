#!/usr/bin/env bash
set -euo pipefail

echo "=== sample tasks from DB ==="
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "
SELECT task_id, status, attempts, max_attempts, title, kind
FROM tasks
ORDER BY updated_at DESC
LIMIT 10;
" || true

echo
echo "=== raw guidance-engine invocation (node) ==="
node -e "
import { generateGuidance } from './server/lib/guidance-engine.js';

const sample = [
  { name: 'execution', status: 'verified' },
  { name: 'atlas', connected: false }
];

const result = generateGuidance(sample);
console.log(JSON.stringify(result, null, 2));
"

echo
echo "=== live endpoint ==="
curl -s http://localhost:3000/api/guidance | jq

echo
echo "=== done ==="
