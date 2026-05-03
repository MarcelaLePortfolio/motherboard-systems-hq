#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "===== PHASE 488 — APPLY MINIMAL WORKER SCHEMA ====="

POSTGRES_CID="$(docker compose ps -q postgres || true)"

if [ -z "$POSTGRES_CID" ]; then
  echo "ERROR: Postgres container not found"
  exit 1
fi

echo
echo "[1] CREATE worker_heartbeats TABLE (IF MISSING)"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" psql -U postgres -d postgres << 'SQL'
CREATE TABLE IF NOT EXISTS worker_heartbeats (
  owner TEXT PRIMARY KEY,
  last_seen_at BIGINT NOT NULL
);
SQL

echo
echo "[2] VERIFY TABLE EXISTS"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c \
  "select tablename from pg_tables where schemaname='public' and tablename='worker_heartbeats';"

echo
echo "[3] RESTART WORKER CLEANLY"
pkill -f phase26_task_worker || true
sleep 1
nohup node server/worker/phase26_task_worker.mjs > logs/phase488_worker.log 2>&1 &

sleep 3

echo
echo "[4] VERIFY HEARTBEATS"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c \
  "select * from worker_heartbeats order by last_seen_at desc limit 5;" || true

echo
echo "[5] VERIFY TASK PROGRESSION"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c \
  "select kind, count(*) from task_events group by kind order by kind;" || true

echo
echo "[6] WORKER LOG"
tail -n 40 logs/phase488_worker.log || true

echo
echo "===== RESULT ====="
echo "Expected:"
echo "- worker_heartbeats now exists"
echo "- worker process running"
echo "- task.started / task.completed begin appearing"

