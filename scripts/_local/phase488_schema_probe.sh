#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "===== PHASE 488 — SCHEMA PROBE (NO MUTATION) ====="

POSTGRES_CID="$(docker compose ps -q postgres || true)"

if [ -z "$POSTGRES_CID" ]; then
  echo "NO_POSTGRES_CONTAINER"
  exit 0
fi

echo
echo "[1] LIST ALL TABLES"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c \
  "select tablename from pg_tables where schemaname='public' order by tablename;"

echo
echo "[2] CHECK TASKS TABLE STRUCTURE"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c "\d tasks" || true

echo
echo "[3] CHECK task_events TABLE STRUCTURE"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c "\d task_events" || true

echo
echo "[4] CHECK FOR ANY WORKER-RELATED TABLES"
docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
  psql -U postgres -d postgres -c \
  "select tablename from pg_tables where schemaname='public' and tablename like '%worker%';"

echo
echo "[5] INTERPRETATION"
echo "- If NO worker tables → migration/bootstrap gap confirmed"
echo "- If worker tables exist but empty → worker not running"
echo "- If worker tables exist + filling → lifecycle should progress"

echo
echo "===== END ====="

