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
# phase35 smoke guards
[[ -n "${WORKER_COMPOSE_BASE:-}" ]] || { echo "FAIL: WORKER_COMPOSE_BASE empty"; exit 1; }
[[ -n "${WORKER_COMPOSE_OVERRIDE:-}" ]] || { echo "FAIL: WORKER_COMPOSE_OVERRIDE empty"; exit 1; }
[[ -f "$WORKER_COMPOSE_BASE" ]] || { echo "FAIL: missing $WORKER_COMPOSE_BASE"; exit 1; }
[[ -f "$WORKER_COMPOSE_OVERRIDE" ]] || { echo "FAIL: missing $WORKER_COMPOSE_OVERRIDE"; exit 1; }

LOG_DIR="tmp"
mkdir -p "$LOG_DIR"
TS="$(date +%s)"
PSQL_BASE=(
  psql "$POSTGRES_URL"
  -v ON_ERROR_STOP=1
  -q
  -X
  -P pager=off
)
echo "== phase35: stop workers (compose: $WORKER_COMPOSE_BASE + $WORKER_COMPOSE_OVERRIDE) =="
docker compose -f "$WORKER_COMPOSE_BASE" -f "$WORKER_COMPOSE_OVERRIDE" down --remove-orphans >/dev/null 2>&1 || true
echo "== phase35: ensure dashboard up (no deps) =="
if docker compose ps -q dashboard >/dev/null 2>&1 && [[ -n "$(docker compose ps -q dashboard)" ]]; then
  echo "dashboard: already present"
else
  docker compose up -d --no-deps dashboard >/dev/null
fi
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


echo "== phase35: start workers (compose: $WORKER_COMPOSE_BASE + $WORKER_COMPOSE_OVERRIDE) =="
docker compose -f "$WORKER_COMPOSE_BASE" -f "$WORKER_COMPOSE_OVERRIDE" config >/dev/null
docker compose -f "$WORKER_COMPOSE_BASE" -f "$WORKER_COMPOSE_OVERRIDE" up -d >/dev/null
echo "== phase35: wait for completion =="
for i in {1..60}; do
  ST="$("${PSQL_BASE[@]}" -t -A -c "SELECT status FROM tasks WHERE id=$TASK_ID;")"
  [[ "$ST" == "completed" ]] && break
  sleep 0.5
done
ST="$("${PSQL_BASE[@]}" -t -A -c "SELECT status FROM tasks WHERE id=$TASK_ID;")"
[[ "$ST" == "completed" ]] || { echo "FAIL: expected completed, got <$ST>"; exit 1; }
echo "== phase35: assert events via DB: exactly 1 running + 1 completed, 0 failed, exactly 1 terminal =="
python3 - <<'PY'
import os, subprocess
POSTGRES_URL = os.environ.get("POSTGRES_URL", "postgres://postgres:postgres@127.0.0.1:5432/postgres")
TASK_ID = os.environ.get("TASK_ID")
if not TASK_ID:
    raise SystemExit("FAIL: TASK_ID env not set for DB assertion")
def psql(q: str) -> str:
    cmd = ["psql", POSTGRES_URL, "-v", "ON_ERROR_STOP=1", "-q", "-X", "-P", "pager=off", "-t", "-A", "-c", q]
    return subprocess.check_output(cmd, text=True).strip()
tables = psql(r"""
SELECT c.table_schema||'.'||c.table_name
FROM information_schema.columns c
WHERE c.column_name='kind'
  AND c.table_schema NOT IN ('pg_catalog','information_schema')
GROUP BY c.table_schema, c.table_name
ORDER BY 1;
""").splitlines()
tables = [t.strip() for t in tables if t.strip()]
chosen = None
for t in tables:
    schema, name = t.split(".", 1)
    cols = psql(f"""
SELECT column_name
FROM information_schema.columns
WHERE table_schema='{schema}' AND table_name='{name}'
ORDER BY ordinal_position;
""").splitlines()
    cols = [c.strip() for c in cols if c.strip()]
    task_cols = [c for c in cols if ("task" in c.lower() and "id" in c.lower())]
    if not task_cols:
        continue
    task_col = task_cols[0]
    try:
        psql(f"SELECT count(*) FROM {t} WHERE {task_col}::text = '{TASK_ID}';")
    except Exception:
        continue
    chosen = (t, task_col)
    break
if not chosen:
    raise SystemExit("FAIL: could not find an events table with kind + task_id-ish column")


table, task_col = chosen
running   = int(psql(f"SELECT count(*) FROM {table} WHERE {task_col}::text='{TASK_ID}' AND kind='task.running';") or "0")
completed = int(psql(f"SELECT count(*) FROM {table} WHERE {task_col}::text='{TASK_ID}' AND kind='task.completed';") or "0")
failed    = int(psql(f"SELECT count(*) FROM {table} WHERE {task_col}::text='{TASK_ID}' AND kind='task.failed';") or "0")
term = completed + failed
print(f"task_id={TASK_ID} table={table} task_col={task_col} running={running} completed={completed} failed={failed} terminal={term}")

if running != 1:
    raise SystemExit(f"FAIL: expected 1 task.running, got {running}")
if completed != 1:
    raise SystemExit(f"FAIL: expected 1 task.completed, got {completed}")
if failed != 0:
    raise SystemExit(f"FAIL: expected 0 task.failed, got {failed}")
if term != 1:
    raise SystemExit(f"FAIL: expected exactly 1 terminal, got {term}")
print("OK phase35 smoke proof (DB events)")
PY
echo "== phase35: PASS =="
