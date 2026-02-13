#!/usr/bin/env bash
set -euo pipefail

pgc() { docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' | head -n1; }
PGC="$(pgc)"
: "${PGC:?ERROR: postgres container not found}"

TASK_ID="smoke.phase32.nullmax.$(date +%s)"
TITLE="smoke phase32 NULL max_attempts"
RUN_ID="smoke.nullmax.$(date +%s)"
OWNER="smoke-nullmax"

echo "=== insert queued task with max_attempts NULL ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  -v task_id="$TASK_ID" -v title="$TITLE" <<'SQL'
\pset pager off
INSERT INTO tasks (task_id, title, status, attempts, max_attempts, created_at, updated_at)
VALUES (:'task_id', :'title', 'queued', 0, NULL, now(), now());
SELECT id, task_id, status, attempts, max_attempts
FROM tasks
WHERE task_id = :'task_id';
SQL

echo
echo "=== claim via phase32_claim_one.sql (prepared) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  -v run_id="$RUN_ID" -v owner="$OWNER" <<SQL
\pset pager off
PREPARE phase32_claim_one(text, text) AS
$(cat server/worker/phase32_claim_one.sql)
;
EXECUTE phase32_claim_one(:'run_id', :'owner');
DEALLOCATE phase32_claim_one;
SQL

echo
echo "=== assert task is now running and owned ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  -v task_id="$TASK_ID" -v run_id="$RUN_ID" -v owner="$OWNER" <<'SQL'
\pset pager off
SELECT
  CASE
    WHEN status='running'
     AND run_id=:'run_id'
     AND claimed_by=:'owner'
    THEN 'OK: claimed NULL max_attempts task'
    ELSE 'FAIL: did not claim as expected'
  END AS verdict,
  id, task_id, status, claimed_by, run_id, attempts, max_attempts
FROM tasks
WHERE task_id = :'task_id';
SQL
