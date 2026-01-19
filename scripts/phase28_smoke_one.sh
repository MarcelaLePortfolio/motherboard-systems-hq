#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
: "${POSTGRES_URL:?POSTGRES_URL required}"
for i in $(seq 1 40); do
  psql "$POSTGRES_URL" -qtAc 'select 1' >/dev/null 2>&1 && break
  sleep 0.25
done
echo "=== phase28: seed failing task ==="
TASK_ID="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -qtAc "
insert into tasks(title, status, meta, created_at, updated_at, attempt, max_attempts, available_at)
values (
  'phase28 smoke forced-fail',
  'queued',
  jsonb_build_object('__phase28','smoke','force_fail', true),
  now(), now(),
  0,
  3,
  now()
)
returning id
")"
[ -n "${TASK_ID}" ] || { echo "FAIL: seed returned empty task id"; exit 1; }
echo "seeded TASK_ID=${TASK_ID}"
echo "=== phase28: generate claim SQL pinned to TASK_ID ==="
CLAIM_SQL="$(mktemp -t phase28_claim_one_smoke.XXXXXX.sql)"
cat > "${CLAIM_SQL}" <<SQL
-- params:
-- \$1 run_id (text)
-- \$2 owner/locked_by (text)
with picked as (
  select id
  from tasks
  where id = ${TASK_ID}
    and status = 'queued'
    and (available_at is null or available_at <= now())
    and (lock_expires_at is null or lock_expires_at <= now())
  for update
)
update tasks t
set status = 'running',
    run_id = \$1,
    locked_by = \$2,
    lock_expires_at = now() + interval '5 minutes',
    updated_at = now()
from picked
where t.id = picked.id
returning t.*;
SQL
echo "=== phase28: run worker WORKER_MAX_CLAIMS=1 (must claim TASK_ID only) ==="
WORKER_MAX_CLAIMS=1 \
WORKER_MAX_ATTEMPTS=3 \
WORKER_BACKOFF_BASE_MS=2000 \
WORKER_BACKOFF_MAX_MS=60000 \
PHASE27_CLAIM_ONE_SQL="${CLAIM_SQL}" \
PHASE27_MARK_SUCCESS_SQL="server/worker/phase28_mark_success.sql" \
PHASE27_MARK_FAILURE_SQL="server/worker/phase28_mark_failure.sql" \
node server/worker/phase26_task_worker.mjs >/dev/null
rm -f "${CLAIM_SQL}" || true

echo "=== phase28: assert tasks row updated (attempt=1, last_error present, available_at set if not terminal) ==="
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -qtAc "
select status,
       attempt,
       (last_error is not null)::int as has_last_error,
       (available_at is not null)::int as has_available_at
from tasks
where id = ${TASK_ID}
" | awk -F'|' '
  NF>=4 {
    status=$1; attempt=$2; has_err=$3; has_avail=$4;
    if(attempt != 1) { print "FAIL: expected attempt=1 got " attempt; exit 1 }
    if(has_err != 1) { print "FAIL: expected last_error present"; exit 1 }
    if(status != "failed" && has_avail != 1) { print "FAIL: expected available_at set for retry"; exit 1 }
  }
  END { if(NR==0) { print "FAIL: no tasks row returned for id"; exit 1 } }
'
echo "=== phase28: assert task.failed event exists with persisted task_id ==="
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -qtAc "
select count(*)
from task_events
where kind='task.failed' and task_id = (${TASK_ID}::text)
" | awk -F'|' '{ if($1 < 1) { print "FAIL: missing task.failed event"; exit 1 } }'

echo "OK phase28_smoke task_id=${TASK_ID}"
