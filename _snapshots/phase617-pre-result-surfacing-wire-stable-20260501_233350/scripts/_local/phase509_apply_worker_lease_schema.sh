#!/usr/bin/env bash
set -euo pipefail

echo "===== PHASE 509 — APPLY WORKER LEASE SCHEMA ====="

docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres << 'SQL'
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS claimed_at BIGINT NULL,
  ADD COLUMN IF NOT EXISTS lease_expires_at BIGINT NULL,
  ADD COLUMN IF NOT EXISTS lease_epoch BIGINT NOT NULL DEFAULT 0;
SQL

echo
echo "[1] Verify worker lease columns"
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c \
  "select column_name, data_type from information_schema.columns where table_schema='public' and table_name='tasks' and column_name in ('claimed_by','claimed_at','lease_expires_at','lease_epoch') order by column_name;"

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
