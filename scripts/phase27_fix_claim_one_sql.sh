
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

DB_URL="${POSTGRES_URL:-${DATABASE_URL:-${PGURL:-}}}"
if [[ -z "${DB_URL}" ]]; then
  echo "ERROR: POSTGRES_URL/DATABASE_URL/PGURL not set"
  exit 1
fi
cols="$(psql "$DB_URL" -Atc "select column_name from information_schema.columns where table_schema='public' and table_name='tasks' order by ordinal_position;")"

has_col() { echo "$cols" | rg -q "^$1$"; }


SCHED_COL=""
if has_col "next_run_at"; then SCHED_COL="next_run_at"; fi
if [[ -z "$SCHED_COL" ]] && has_col "next_attempt_at"; then SCHED_COL="next_attempt_at"; fi
if [[ -z "$SCHED_COL" ]] && has_col "run_at"; then SCHED_COL="run_at"; fi
if [[ -z "$SCHED_COL" ]] && has_col "available_at"; then SCHED_COL="available_at"; fi
if [[ -z "$SCHED_COL" ]] && has_col "not_before"; then SCHED_COL="not_before"; fi
if [[ -z "$SCHED_COL" ]] && has_col "scheduled_at"; then SCHED_COL="scheduled_at"; fi
if [[ -z "$SCHED_COL" ]]; then
  echo "ERROR: could not find a scheduling column on public.tasks (tried next_run_at, next_attempt_at, run_at, available_at, not_before, scheduled_at)"
  echo "Columns found:"
  echo "$cols" | sed -n '1,200p'
  exit 1
fi

echo "Using scheduling column: $SCHED_COL"

mkdir -p server/worker
cat > server/worker/phase27_claim_one.sql <<EOF2
-- phase27_claim_one.sql
-- Params:
--   \$1 = lease_owner (text)
--   \$2 = lease_expires_at (timestamptz)

with c as (
  select id
  from tasks
  where
    (coalesce(status,'') in ('created','queued','requeued') or status is null)
    and (coalesce(${SCHED_COL}, to_timestamp(0)) <= now())
  order by coalesce(priority,0) desc, id asc
  for update skip locked
  limit 1
)
update tasks t
set
  status = 'running',
  run_id = coalesce(t.run_id, gen_random_uuid()::text),
  lease_owner = \$1,
  lease_expires_at = \$2,
  updated_at = now()
from c
where t.id = c.id
returning t.*;
EOF2

echo "OK: rewrote server/worker/phase27_claim_one.sql"
