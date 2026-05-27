set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
: "${POSTGRES_URL:?export POSTGRES_URL=postgres://... first}"
echo "== stop workers (avoid race) =="
docker compose -f docker-compose.worker.phase32.yml -f docker-compose.worker.phase34.yml stop workerA workerB
echo "== stale heartbeat owner verify-dead =="
PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -P pager=off -c \
"insert into worker_heartbeats(owner,last_seen_at)
 values('verify-dead',(extract(epoch from now())*1000)::bigint - 999999)
 on conflict (owner) do update set last_seen_at=excluded.last_seen_at;"
echo "== create running task claimed by verify-dead with expired lease; capture TASK_ID =="
TASK_ID="$(
  PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -At <<'SQL'
insert into tasks(
  title,agent,status,source,trace_id,meta,
  claimed_by,claimed_at,lease_expires_at,lease_epoch
)
values(
  'phase34-reclaim-now',
  'smoke',
  'running',
  'smoke',
  'phase34-reclaim-now-'||extract(epoch from now())::bigint::text,
  '{}'::jsonb,
  'verify-dead',
  (extract(epoch from now())*1000)::bigint,
  (extract(epoch from now())*1000)::bigint - 1,
  1
)
returning id;
SQL
)"
TASK_ID="$(echo "$TASK_ID" | tr -d '[:space:]')"
typeset -p TASK_ID
[[ "$TASK_ID" =~ ^[0-9]+$ ]] || { echo "bad TASK_ID=<$TASK_ID>"; exit 1; }
echo "== confirm pre-reclaim row =="
PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -P pager=off -c \
"select id,status,claimed_by,lease_expires_at,lease_epoch from tasks where id=$TASK_ID;"
echo "== reclaim (EXPECT reclaimed=1) =="
PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -P pager=off -c "
WITH params AS (
  SELECT 30000::bigint AS stale_heartbeat_ms,
         (extract(epoch from now())*1000)::bigint AS now_ms
),
dead AS (
  SELECT wh.owner
  FROM worker_heartbeats wh, params p
  WHERE wh.last_seen_at < (p.now_ms - p.stale_heartbeat_ms)
),
r AS (
  UPDATE tasks t
  SET status='created',
      claimed_by=NULL,
      claimed_at=NULL,
      lease_expires_at=NULL,
      lease_epoch=COALESCE(t.lease_epoch,0)+1
  WHERE t.status='running'
    AND (
      (t.lease_expires_at IS NOT NULL AND t.lease_expires_at <= (extract(epoch from now())*1000)::bigint)
      OR (t.claimed_by IS NOT NULL AND t.claimed_by IN (SELECT owner FROM dead))
      OR (t.claimed_by IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM worker_heartbeats wh2 WHERE wh2.owner = t.claimed_by
          ))
    )
  RETURNING t.id
)
SELECT count(*)::bigint AS reclaimed FROM r;
"
echo "== confirm post-reclaim row (should be created + unclaimed) =="
PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -P pager=off -c \
"select id,status,claimed_by,lease_expires_at,lease_epoch from tasks where id=$TASK_ID;"
echo "== restart workers (should claim + complete) =="
docker compose -f docker-compose.worker.phase32.yml -f docker-compose.worker.phase34.yml start workerA workerB
sleep 2
echo "== confirm exactly 2 events + 1 terminal =="
PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -P pager=off -c \
"select kind, count(*) n
 from task_events
 where task_id='$TASK_ID'
 group by kind
 order by kind;"
PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -P pager=off -c \
"select count(*) as terminal_n
 from task_events
 where task_id='$TASK_ID' and kind in ('task.completed','task.failed');"
