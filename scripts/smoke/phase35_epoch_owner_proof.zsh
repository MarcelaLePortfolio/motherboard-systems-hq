#!/usr/bin/env zsh
set -euo pipefail
if [[ -z "${ZSH_VERSION:-}" ]]; then
  exec zsh "$0" "$@"
fi
setopt NO_BANG_HIST
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
: "${POSTGRES_URL:=postgres://postgres:postgres@127.0.0.1:5432/postgres}"
: "${API_BASE:=http://127.0.0.1:8080}"
: "${PHASE34_STALE_HEARTBEAT_MS:=60000}"
: "${WORKER_COMPOSE_BASE:=docker-compose.worker.phase32.yml}"
: "${WORKER_COMPOSE_OVERRIDE:=docker-compose.worker.phase34.yml}"
LOG_DIR="tmp"
mkdir -p "$LOG_DIR"
TS="$(date +%s)"
EVLOG="$LOG_DIR/phase35-epoch-owner-events.$TS.log"
PSQL_BASE=(
  psql "$POSTGRES_URL"
  -v ON_ERROR_STOP=1
  -q
  -X
  -P pager=off
)
echo "== phase35: stop workers (compose: $WORKER_COMPOSE) =="
docker compose -f "$WORKER_COMPOSE_BASE" -f "$WORKER_COMPOSE_OVERRIDE" down --remove-orphans >/dev/null 2>&1 || true
echo "== phase35: ensure dashboard up (no deps) =="
docker compose up -d --no-deps dashboard >/dev/null
echo "== phase35: start SSE capture =="
curl -sS -N -H "Accept: text/event-stream" "$API_BASE/events/task-events" >"$EVLOG" &
CURLPID=$!
sleep 1
TITLE="phase35-epoch-owner-$TS"
STALE_OWNER="phase35-stale-owner-$TS"
echo "== phase35: insert stale RUNNING task (expired lease) =="
TASK_ID="$("${PSQL_BASE[@]}" -t -A <<SQL
WITH ins AS (
  INSERT INTO tasks(title, agent, status, source, trace_id, meta, claimed_by, claimed_at, lease_expires_at, lease_epoch)
  VALUES (
    '$TITLE',
    'phase35.smoke',
    'running',
    'smoke',
    'phase35-$TS',
    '{}'::jsonb,
    '$STALE_OWNER',
    (extract(epoch from now())*1000)::bigint - 5000,
    (extract(epoch from now())*1000)::bigint - 1,
    1
  )
  RETURNING id
)
SELECT id FROM ins;
SQL
)"
[[ -n "$TASK_ID" ]] || { echo "FAIL: no TASK_ID"; exit 1; }
echo "TASK_ID=$TASK_ID"
echo "== phase35: pre-reclaim row =="
"${PSQL_BASE[@]}" -q -X -c "SELECT id,status,claimed_by,lease_epoch,lease_expires_at FROM tasks WHERE id=$TASK_ID;"


echo "== phase35: reclaim (EXPECT reclaimed=1) =="
RECLAIMED_CNT="$("${PSQL_BASE[@]}" -t -A <<SQL
WITH params AS (
  SELECT $PHASE34_STALE_HEARTBEAT_MS::bigint AS stale_heartbeat_ms,
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
  WHERE t.id=$TASK_ID
    AND t.status='running'
    AND (
      (t.lease_expires_at IS NOT NULL AND t.lease_expires_at <= (extract(epoch from now())*1000)::bigint)
      OR (t.claimed_by IS NOT NULL AND t.claimed_by IN (SELECT owner FROM dead))
      OR (t.claimed_by IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM worker_heartbeats wh2 WHERE wh2.owner = t.claimed_by
          ))
    )
  RETURNING t.id
)
SELECT count(*)::bigint FROM r;
SQL
)"
[[ "$RECLAIMED_CNT" == "1" ]] || { echo "FAIL: reclaim expected 1 got <$RECLAIMED_CNT>"; exit 1; }


echo "== phase35: post-reclaim row (EXPECT created + unclaimed + lease_epoch=2) =="
POST_ROW="$("${PSQL_BASE[@]}" -t -A -c "SELECT status||'|'||COALESCE(claimed_by,'')||'|'||lease_epoch::text FROM tasks WHERE id=$TASK_ID;")"
echo "$POST_ROW"
[[ "$POST_ROW" == "created||2" ]] || { echo "FAIL: post-reclaim row mismatch expected <created||2> got <$POST_ROW>"; exit 1; }


echo "== phase35: stale mark_success attempt (wrong owner+epoch) must affect 0 rows =="
AFFECTED="$("${PSQL_BASE[@]}" -t -A <<SQL
WITH u AS (
  UPDATE tasks
  SET status='completed',
      lease_expires_at=NULL
  WHERE id=$TASK_ID::bigint
    AND status='running'
    AND claimed_by='$STALE_OWNER'
    AND lease_epoch=1::bigint
  RETURNING id
)
SELECT count(*)::bigint FROM u;
SQL
)"
[[ "$AFFECTED" == "0" ]] || { echo "FAIL: stale mark_success should affect 0 rows got <$AFFECTED>"; exit 1; }


echo "== phase35: confirm still created + unclaimed + lease_epoch=2 =="
POST2="$("${PSQL_BASE[@]}" -t -A -c "SELECT status||'|'||COALESCE(claimed_by,'')||'|'||lease_epoch::text FROM tasks WHERE id=$TASK_ID;")"
echo "$POST2"
[[ "$POST2" == "created||2" ]] || { echo "FAIL: after stale attempt row mismatch expected <created||2> got <$POST2>"; exit 1; }


echo "== phase35: start workers (compose: ) =="

docker compose -f "" config >/dev/null
docker compose -f "$WORKER_COMPOSE_BASE" -f "$WORKER_COMPOSE_OVERRIDE" up -d >/dev/null
echo "== phase35: wait for completion =="
for i in {1..60}; do
  ST="$("${PSQL_BASE[@]}" -t -A -c "SELECT status FROM tasks WHERE id=$TASK_ID;")"
  [[ "$ST" == "completed" ]] && break
  sleep 0.5
done
ST="$("${PSQL_BASE[@]}" -t -A -c "SELECT status FROM tasks WHERE id=$TASK_ID;")"
[[ "$ST" == "completed" ]] || { echo "FAIL: expected completed, got <$ST>"; exit 1; }
echo "== phase35: stop SSE capture =="
kill -TERM "$CURLPID" 2>/dev/null || true
wait "$CURLPID" || true
echo "== phase35: assert events: exactly 1 running + 1 completed for TASK_ID, exactly 1 terminal =="
python3 - <<PY
import json, pathlib
p = pathlib.Path("$EVLOG")
txt = p.read_text(encoding="utf-8", errors="replace").splitlines()
task_id = str("$TASK_ID")
events = []
for line in txt:
    if not line.startswith("data: "):
        continue
    payload = line[len("data: "):].strip()
    if not payload or not payload.startswith("{"):
        continue
    try:
        obj = json.loads(payload)
    except Exception:
        continue
    if str(obj.get("task_id")) != task_id:
        continue
    events.append(obj)
kinds = [e.get("kind") for e in events]
running = sum(1 for k in kinds if k == "task.running")
completed = sum(1 for k in kinds if k == "task.completed")
failed = sum(1 for k in kinds if k == "task.failed")
term = completed + failed
print(f"task_id={task_id} running={running} completed={completed} failed={failed} terminal={term}")
if running != 1:
    raise SystemExit(f"FAIL: expected 1 task.running, got {running}")
if completed != 1:
    raise SystemExit(f"FAIL: expected 1 task.completed, got {completed}")
if failed != 0:
    raise SystemExit(f"FAIL: expected 0 task.failed, got {failed}")
if term != 1:
    raise SystemExit(f"FAIL: expected exactly 1 terminal, got {term}")
print("OK phase35 smoke proof")
PY
echo "== phase35: PASS =="
