#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
: "${POSTGRES_URL:?POSTGRES_URL required}"

for i in $(seq 1 40); do
  psql "$POSTGRES_URL" -qtAc 'select 1' >/dev/null 2>&1 && break
  sleep 0.25
done

TASK_ID="$(psql "$POSTGRES_URL" -qtAc "
insert into tasks(status, attempts, payload, created_at, updated_at)
values ('queued', 0, jsonb_build_object('__phase28','smoke','force_fail', true), now(), now())
returning id
")"

WORKER_MAX_CLAIMS=1 \
WORKER_MAX_ATTEMPTS=3 \
WORKER_BACKOFF_BASE_MS=2000 \
WORKER_BACKOFF_MAX_MS=60000 \
node server/worker/phase26_task_worker.mjs

psql "$POSTGRES_URL" -qtAc "
select status, attempts, last_error is not null, next_run_at is not null
from tasks where id=${TASK_ID}
"

psql "$POSTGRES_URL" -qtAc "
select count(*) from task_events
where kind='task.failed' and task_id=${TASK_ID}
"
