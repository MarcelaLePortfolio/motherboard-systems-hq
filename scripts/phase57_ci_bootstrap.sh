#!/usr/bin/env bash
set -euo pipefail

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-motherboard_systems_hq}"

docker compose up -d postgres

PG_CTN="${COMPOSE_PROJECT_NAME}-postgres-1"
if ! docker ps --format '{{.Names}}' | grep -qx "$PG_CTN"; then
  echo "ERROR: expected postgres container not found: $PG_CTN" >&2
  docker ps --format 'table {{.Names}}\t{{.Status}}' >&2 || true
  exit 1
fi

echo "Waiting for postgres to be ready..."
for i in $(seq 1 60); do
  if docker exec "$PG_CTN" pg_isready -U postgres >/dev/null 2>&1; then
    echo "Postgres ready."
    break
  fi
  sleep 1
done

echo "Ensuring run_view exists (Phase 36.1) before dashboard starts..."
docker exec -i "$PG_CTN" psql -U postgres -d postgres -v ON_ERROR_STOP=1 < drizzle_pg/0007_phase36_1_run_view.sql

echo "OK: run_view ensured."
