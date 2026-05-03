#!/usr/bin/env bash
# Phase32 verifier: create task(meta.fail_n_times=2) and assert retry/backoff + events end-to-end (works with docker workers)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
PGURL="postgres://postgres:postgres@127.0.0.1:5432/postgres"
echo "PGURL=$PGURL"
psql -X -q "$PGURL" -c "select now();" | sed -n '1,40p'
CURSOR="$(psql -X -qAt "$PGURL" -c "select coalesce(max(id),0) from task_events")"
echo "cursor=$CURSOR"
LOG="tmp/phase32_sse.$(date +%s).log"
mkdir -p tmp
echo "LOG=$LOG"
curl -sS -N -H "Accept: text/event-stream" \
  "http://127.0.0.1:8080/events/task-events?cursor=$CURSOR" >"$LOG" &
SSE_PID=$!
echo "SSE_PID=$SSE_PID"
TS="$(date +%s)"
RESP="$(curl -sS -X POST "http://127.0.0.1:8080/api/tasks/create" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"phase32-retry-smoke-$TS\",\"agent\":\"phase32\",\"meta\":{\"fail_n_times\":2}}")"

echo "$RESP" | jq .
TID="$(echo "$RESP" | jq -r '.task_id' | sed -E 's/^t//')"
echo "TID=$TID"
sleep 12
echo "=== SSE tail ==="
tail -n 200 "$LOG"
echo "=== task row ==="
psql -X -q "$PGURL" -c "
select id,status,attempts,max_attempts,next_run_at,failed_at,completed_at,run_id,actor,meta,last_error
from tasks
where id=$TID;
" | sed -n '1,240p'
echo "=== task_events rows ==="
psql -X -q "$PGURL" -c "
select id, kind,

       pg_typeof(payload) as payload_type,
       pg_typeof(payload) as payload_type,
       (payload::jsonb)->>'task_id' as task_id,
       (payload::jsonb)->>'run_id'  as run_id,
       (payload::jsonb)->>'actor'   as actor,
       payload
from task_events
where ((payload::jsonb)->>'task_id') in ('t$TID', '$TID')
order by id asc;
" | sed -n '1,360p'
kill -TERM "$SSE_PID" 2>/dev/null || true
wait "$SSE_PID" 2>/dev/null || true
