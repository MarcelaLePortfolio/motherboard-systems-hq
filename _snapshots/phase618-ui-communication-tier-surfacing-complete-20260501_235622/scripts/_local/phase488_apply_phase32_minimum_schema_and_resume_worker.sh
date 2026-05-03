#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs logs

REPORT="docs/phase488_apply_phase32_minimum_schema_and_resume_worker.txt"
WORKER_LOG="logs/phase488_worker_phase32_after_schema_fix.log"
POSTGRES_CID="$(docker compose ps -q postgres || true)"

if [ -z "${POSTGRES_CID}" ]; then
  echo "ERROR: postgres container not found"
  exit 1
fi

{
  echo "PHASE 488 — APPLY PHASE32 MINIMUM SCHEMA + RESUME WORKER"
  echo "Timestamp: $(date)"
  echo "========================================================"
  echo

  echo "[1] PRECHECK: LIVE tasks COLUMNS BEFORE"
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select column_name, data_type from information_schema.columns where table_schema='public' and table_name='tasks' order by ordinal_position;"
  echo

  echo "[2] APPLY MINIMAL PHASE32-COMPATIBLE TASKS SCHEMA"
} > "$REPORT"

docker exec -i -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres >> "$REPORT" 2>&1 <<'SQL'
BEGIN;

ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS attempts integer NOT NULL DEFAULT 0;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS next_run_at timestamptz NULL;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS claimed_by text NULL;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS completed_at timestamptz NULL;

UPDATE public.tasks
SET attempts = COALESCE(attempt, 0)
WHERE attempts IS NULL;

UPDATE public.tasks
SET next_run_at = COALESCE(next_run_at, available_at)
WHERE next_run_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_status_next_run ON public.tasks(status, next_run_at);

COMMIT;
SQL

{
  echo
  echo "[3] VERIFY tasks COLUMNS AFTER"
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c "\d+ tasks"
  echo

  echo "[4] RESTART WORKER WITH EXPLICIT PHASE32 SQL"
} >> "$REPORT"

pkill -f phase26_task_worker 2>/dev/null || true
sleep 1

PHASE32_CLAIM_ONE_SQL="server/worker/phase32_claim_one.sql" \
PHASE32_MARK_SUCCESS_SQL="server/worker/phase32_mark_success.sql" \
PHASE32_MARK_FAILURE_SQL="server/worker/phase32_mark_failure.sql" \
POSTGRES_URL="postgresql://postgres:postgres@127.0.0.1:5432/postgres" \
DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:5432/postgres" \
nohup node server/worker/phase26_task_worker.mjs > "$WORKER_LOG" 2>&1 &

sleep 8

{
  echo
  echo "[5] WORKER PROCESS"
  ps aux | grep -E 'phase26_task_worker' | grep -v grep || echo "WORKER_NOT_RUNNING"
  echo

  echo "[6] WORKER LOG TAIL"
  tail -n 120 "$WORKER_LOG" || true
  echo

  echo "[7] TASK EVENT COUNTS"
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select kind, count(*) from task_events group by kind order by kind;"
  echo

  echo "[8] TASK STATUS COUNTS"
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select status, count(*) from tasks group by status order by status;"
  echo

  echo "[9] /api/runs SNAPSHOT"
  curl -s --max-time 8 http://localhost:3000/api/runs | head -c 1600 || true
  echo
  echo

  echo "[10] TASK EVENTS STREAM SAMPLE"
} >> "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1 || true
import urllib.request, time
url = "http://localhost:3000/events/task-events"
req = urllib.request.Request(url, headers={"Accept": "text/event-stream"})
start = time.time()
count = 0
try:
    with urllib.request.urlopen(req, timeout=8) as resp:
        for raw in resp:
            line = raw.decode("utf-8", errors="replace").rstrip("\n")
            print(line)
            count += 1
            if time.time() - start > 8 or count >= 80:
                break
except Exception as e:
    print(f"TASK_EVENTS_CAPTURE_ERROR: {e}")
PY

{
  echo
  echo "[11] VERDICT"
  echo "- If task.completed or task.failed appear, lifecycle corridor is advancing"
  echo "- If task.running appears but completion fails, result SQL is the next boundary"
  echo "- If tasks remain queued with no new kinds, inspect Phase32 claim/result contract next"
  echo
  echo "RUN COMPLETE"
} >> "$REPORT"

sed -n '1,360p' "$REPORT"
