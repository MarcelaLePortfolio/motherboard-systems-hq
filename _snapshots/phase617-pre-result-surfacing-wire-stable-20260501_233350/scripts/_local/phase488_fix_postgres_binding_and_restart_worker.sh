#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p logs docs

REPORT="docs/phase488_fix_postgres_binding.txt"
LOG="logs/phase488_worker_fixed.log"

{
  echo "PHASE 488 — FIX POSTGRES BINDING + WORKER RELAUNCH"
  echo "Timestamp: $(date)"
  echo "==============================================="
  echo

  echo "[1] ENSURE POSTGRES CONTAINER RUNNING"
  docker compose up -d postgres || true
  sleep 3
  docker compose ps postgres || true
  echo

  echo "[2] VERIFY PORT 5432 LISTENING"
} > "$REPORT"

lsof -nP -iTCP:5432 -sTCP:LISTEN >> "$REPORT" 2>&1 || echo "PORT_NOT_LISTENING" >> "$REPORT"

{
  echo
  echo "[3] LOCAL TCP PROBE"
} >> "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1
import socket
s = socket.socket()
s.settimeout(3)
try:
    s.connect(("127.0.0.1", 5432))
    print("tcp_connect_ok")
except Exception as e:
    print(f"tcp_connect_fail {e}")
finally:
    s.close()
PY

{
  echo
  echo "[4] RESTART WORKER WITH EXPLICIT DB URL"
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
  echo "[5] WORKER STATUS"
  ps aux | grep -E 'phase26_task_worker' | grep -v grep || echo "WORKER_NOT_RUNNING"
  echo

  echo "[6] WORKER LOG"
  tail -n 60 "$LOG" || true
  echo

  echo "[7] TASK EVENT COUNTS"
} >> "$REPORT"

POSTGRES_CID="$(docker compose ps -q postgres || true)"
if [ -n "$POSTGRES_CID" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select kind, count(*) from task_events group by kind order by kind;" \
    >> "$REPORT" 2>&1 || true
else
  echo "NO_POSTGRES_CONTAINER" >> "$REPORT"
fi

{
  echo
  echo "[8] VERDICT"
  echo "- If tcp_connect_ok + no ECONNREFUSED → DB fixed"
  echo "- If task.started appears → lifecycle unlocked"
  echo "- If still failing → deeper DB config issue"
  echo
  echo "FIX ATTEMPT COMPLETE"
} >> "$REPORT"

sed -n '1,260p' "$REPORT"
