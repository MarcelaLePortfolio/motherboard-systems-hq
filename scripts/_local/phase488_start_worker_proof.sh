#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "===== PHASE 488 — START WORKER (PROOF ONLY) ====="

echo
echo "[1] START WORKER PROCESS"
nohup node server/worker/phase26_task_worker.mjs > logs/phase488_worker.log 2>&1 &

sleep 2

echo
echo "[2] VERIFY WORKER PROCESS"
ps aux | grep -E 'phase26_task_worker' | grep -v grep || echo "WORKER_NOT_RUNNING"

echo
echo "[3] WAIT FOR HEARTBEAT (5s)"
sleep 5

POSTGRES_CID="$(docker compose ps -q postgres || true)"

echo
echo "[4] CHECK worker_heartbeats TABLE (MAY FAIL IF SCHEMA MISSING)"
if [ -n "${POSTGRES_CID}" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select * from worker_heartbeats order by last_seen_at desc limit 5;" || true
fi

echo
echo "[5] CHECK TASK EVENTS PROGRESSION"
if [ -n "${POSTGRES_CID}" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select kind, count(*) from task_events group by kind order by kind;" || true
fi

echo
echo "[6] LOG TAIL"
tail -n 60 logs/phase488_worker.log || true

echo
echo "===== RESULT ====="
echo "If worker runs but table missing → schema gap confirmed"
echo "If worker runs and events progress → lifecycle unlocked"
echo "If worker fails → boot path issue"

