#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs logs

REPORT="docs/phase488_db_boundary_and_worker_relaunch.txt"
LOG="logs/phase488_worker_phase27_explicit.log"

{
  echo "PHASE 488 — VERIFY DB BOUNDARY + RELAUNCH WORKER"
  echo "Timestamp: $(date)"
  echo "==============================================="
  echo

  echo "[1] DOCKER / POSTGRES READINESS"
  docker info >/dev/null 2>&1 && echo "docker_ready" || echo "docker_not_ready"
  docker compose ps postgres || true
  echo
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  echo

  echo "[2] LOCAL TCP PROBE"
} > "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1 || true
import socket
s = socket.socket()
s.settimeout(3)
try:
    s.connect(("127.0.0.1", 5432))
    print("tcp_connect_ok 127.0.0.1:5432")
except Exception as e:
    print(f"tcp_connect_fail 127.0.0.1:5432 {e}")
finally:
    s.close()
PY

{
  echo
  echo "[3] SERVER DB ENV SIGNALS"
  env | grep -E 'POSTGRES_URL|DATABASE_URL|DB_URL|PGURL' || echo "NO_DB_ENV_IN_SHELL"
  echo
  echo "[4] RELAUNCH WORKER WITH EXPLICIT LOCAL POSTGRES URL"
} >> "$REPORT"

pkill -f phase26_task_worker 2>/dev/null || true
sleep 1

PHASE27_CLAIM_ONE_SQL="server/worker/phase27_claim_one.sql" \
PHASE27_MARK_SUCCESS_SQL="server/worker/phase27_mark_success.sql" \
PHASE27_MARK_FAILURE_SQL="server/worker/phase27_mark_failure.sql" \
POSTGRES_URL="postgresql://postgres:postgres@127.0.0.1:5432/postgres" \
DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:5432/postgres" \
nohup node server/worker/phase26_task_worker.mjs > "$LOG" 2>&1 &

sleep 6

{
  echo
  echo "[5] WORKER PROCESS"
  ps aux | grep -E 'phase26_task_worker' | grep -v grep || echo "WORKER_NOT_RUNNING"
  echo

  echo "[6] WORKER LOG TAIL"
  tail -n 80 "$LOG" || true
  echo

  echo "[7] TASK EVENT COUNTS (HTTP VIA SERVER)"
  curl -s --max-time 10 http://localhost:3000/api/runs | head -c 1200 || true
  echo
  echo

  echo "[8] TASK EVENTS STREAM SAMPLE"
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
  echo "[9] VERDICT"
  echo "- If tcp_connect_fail or docker_not_ready: DB availability boundary is the blocker"
  echo "- If worker still shows ECONNREFUSED: local Postgres binding is the blocker"
  echo "- If worker stays up and new task kinds appear: env wiring was the blocker"
  echo
  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,260p' "$REPORT"
