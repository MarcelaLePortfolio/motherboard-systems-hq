#!/usr/bin/env bash
set -euo pipefail

echo "Injecting mock guidance into latest task via Docker Postgres..."

docker compose exec -T postgres psql -U postgres -d postgres <<SQL
UPDATE tasks
SET payload = jsonb_set(
  COALESCE(payload, '{}'::jsonb),
  '{guidance}',
  '{
    "classification": "warning",
    "outcome": "Mock guidance injected for UI verification.",
    "explanation": "This is a simulated guidance payload to confirm Phase 626 rendering."
  }'::jsonb,
  true
)
WHERE id = (
  SELECT id FROM tasks ORDER BY id DESC LIMIT 1
);

SELECT id, payload->'guidance' AS guidance
FROM tasks
ORDER BY id DESC
LIMIT 1;
SQL

echo "Done. Refresh dashboard to verify guidance UI."
