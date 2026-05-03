#!/bin/bash
set -e

echo "Inspecting completion readiness..."

echo ""
echo "Success SQL:"
cat server/worker/phase32_mark_success.sql

echo ""
echo "Current running tasks:"
docker compose exec postgres psql -U postgres -d postgres -c "
select id, task_id, title, status, run_id, claimed_by, completed_at, updated_at
from tasks
order by id desc
limit 10;
"

echo ""
echo "Worker file completion references:"
grep -n "mark_success\|mark_failure\|completed\|claimOnce" server/worker/phase26_task_worker.mjs || true
