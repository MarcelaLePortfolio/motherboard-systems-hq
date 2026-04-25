#!/usr/bin/env bash
set -euo pipefail

echo "===== PHASE 508 — APPLY WORKER HEARTBEAT SCHEMA ====="

docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres << 'SQL'
CREATE TABLE IF NOT EXISTS worker_heartbeats (
  owner TEXT PRIMARY KEY,
  last_seen_at BIGINT NOT NULL
);
SQL

echo
echo "[1] Verify worker_heartbeats exists"
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c \
  "select tablename from pg_tables where schemaname='public' and tablename='worker_heartbeats';"

echo
echo "[2] Restart worker"
docker compose restart worker

sleep 5

echo
echo "[3] Compose status"
docker compose ps

echo
echo "[4] Worker logs"
docker logs --tail 120 motherboard_systems_hq-worker-1
