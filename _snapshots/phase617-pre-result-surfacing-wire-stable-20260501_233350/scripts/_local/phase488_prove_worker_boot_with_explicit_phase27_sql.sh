#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs logs

REPORT="docs/phase488_prove_worker_boot_with_explicit_phase27_sql.txt"
LOG="logs/phase488_worker_phase27_explicit.log"

CLAIM_SQL="server/worker/phase27_claim_one.sql"
SUCCESS_SQL="server/worker/phase27_mark_success.sql"
FAIL_SQL="server/worker/phase27_mark_failure.sql"

{
  echo "PHASE 488 — PROVE WORKER BOOT WITH EXPLICIT PHASE27 SQL"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] REQUIRED SQL FILES"
  for f in "$CLAIM_SQL" "$SUCCESS_SQL" "$FAIL_SQL"; do
    if [ -f "$f" ]; then
      echo "FOUND $f"
    else
      echo "MISSING $f"
    fi
  done
  echo
} > "$REPORT"

for f in "$CLAIM_SQL" "$SUCCESS_SQL" "$FAIL_SQL"; do
  test -f "$f"
done

pkill -f phase26_task_worker 2>/dev/null || true
sleep 1

PHASE27_CLAIM_ONE_SQL="$CLAIM_SQL" \
PHASE27_MARK_SUCCESS_SQL="$SUCCESS_SQL" \
PHASE27_MARK_FAILURE_SQL="$FAIL_SQL" \
nohup node server/worker/phase26_task_worker.mjs > "$LOG" 2>&1 &

sleep 6

POSTGRES_CID="$(docker compose ps -q postgres || true)"

{
  echo "[2] WORKER PROCESS CHECK"
  ps aux | grep -E 'phase26_task_worker' | grep -v grep || echo "WORKER_NOT_RUNNING"
  echo

  echo "[3] WORKER LOG TAIL"
  tail -n 80 "$LOG" || true
  echo

  echo "[4] TASK EVENT COUNTS"
  if [ -n "${POSTGRES_CID}" ]; then
    docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
      psql -U postgres -d postgres -c \
      "select kind, count(*) from task_events group by kind order by kind;" || true
  else
    echo "NO_POSTGRES_CONTAINER"
  fi
  echo

  echo "[5] /api/runs SAMPLE"
  curl -s --max-time 10 http://localhost:3000/api/runs | head -c 1200 || true
  echo
  echo

  echo "[6] TASK EVENTS STREAM SAMPLE"
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
  echo "[7] VERDICT TARGET"
  echo "- If worker stays up and task.started/task.completed appear, boot omission confirmed"
  echo "- If worker still fails, inspect SQL contract mismatch next"
  echo
  echo "PROOF COMPLETE"
} >> "$REPORT"

sed -n '1,260p' "$REPORT"
