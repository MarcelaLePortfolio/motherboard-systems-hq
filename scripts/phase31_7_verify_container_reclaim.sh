#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p tmp
PG="motherboard_systems_hq-postgres-1"
docker ps --format '{{.Names}}' | rg -x "$PG" >/dev/null
docker exec -i "$PG" sh -lc 'psql -U postgres -d postgres -Atc "select 1;"' >/dev/null
BASE_EVENT_ID="$(docker exec -i "$PG" sh -lc 'psql -U postgres -d postgres -Atc "select coalesce(max(id),0) from task_events;"')"
BASE_TASK_ID="$(docker exec -i "$PG" sh -lc 'psql -U postgres -d postgres -Atc "select coalesce(max(id),0) from tasks;"')"
: "${BASE_EVENT_ID:?missing BASE_EVENT_ID}"
: "${BASE_TASK_ID:?missing BASE_TASK_ID}"
echo "BASE_EVENT_ID=$BASE_EVENT_ID BASE_TASK_ID=$BASE_TASK_ID"
end=$((SECONDS+600))
still_locked="1"
while (( SECONDS < end )); do
  docker exec -i "$PG" sh -lc "psql -U postgres -d postgres -v ON_ERROR_STOP=1 -Atc \
\"select coalesce(max((lock_expires_at > now())::int),0)
  from tasks
  where id > $BASE_TASK_ID
    and status in ('queued','running')
    and locked_by is not null;\"" > tmp/still_locked.txt
  still_locked="$(tr -d '[:space:]' < tmp/still_locked.txt)"
  echo "still_locked=$still_locked"
  [[ "$still_locked" == "0" ]] && break
  sleep 5
done
[[ "$still_locked" == "0" ]] || { echo "lock_wait_timeout" >&2; exit 1; }
echo "lock_wait_ok"
docker exec -i "$PG" sh -lc "psql -U postgres -d postgres -Atc \
\"select count(*) from (
  select (payload_jsonb->>'task_id') as task_id
  from task_events
  where id > $BASE_EVENT_ID and kind='task.running'
  group by 1
  having count(*) > 1
) x;\"" > tmp/dbl.txt
docker exec -i "$PG" sh -lc "psql -U postgres -d postgres -Atc \
\"with ev as (
  select id, kind, (payload_jsonb->>'task_id')::bigint as task_id
  from task_events
  where id > $BASE_EVENT_ID and payload_jsonb ? 'task_id'
),
b as (
  select task_id,
         min(id) filter (where kind='task.running')   as r,
         min(id) filter (where kind='task.completed') as c,
         min(id) filter (where kind='task.failed')    as f
  from ev
  group by task_id
)
select count(*) from b
where (c is not null and (r is null or r > c))
   or (f is not null and (r is null or r > f));\"" > tmp/ord.txt
docker exec -i "$PG" sh -lc "psql -U postgres -d postgres -Atc \
\"select count(*) from tasks
  where id > $BASE_TASK_ID
    and ((status='failed' and failed_at is null)
      or (status<>'failed' and failed_at is not null));\"" > tmp/fc.txt
dbl="$(tr -d '[:space:]' < tmp/dbl.txt)"
ord="$(tr -d '[:space:]' < tmp/ord.txt)"
fc="$(tr -d '[:space:]' < tmp/fc.txt)"
echo "dbl_running=$dbl ordering_violations=$ord failed_constraint_violations=$fc"
[[ "$dbl" == "0" && "$ord" == "0" && "$fc" == "0" ]]
echo "invariants_ok"
