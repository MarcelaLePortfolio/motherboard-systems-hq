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
for i in $(seq 1 90); do
  if docker exec "$PG_CTN" pg_isready -U postgres >/dev/null 2>&1; then
    echo "pg_isready: ready."
    break
  fi
  sleep 1
done

echo "Waiting for stable SQL connectivity (handles initdb restart race)..."
for i in $(seq 1 90); do
  if docker exec "$PG_CTN" psql -h 127.0.0.1 -U postgres -d postgres -v ON_ERROR_STOP=1 -c "select 1" >/dev/null 2>&1; then
    echo "psql: ready."
    break
  fi
  sleep 1
done

psql_in_ctn() {
  docker exec -i "$PG_CTN" psql -h 127.0.0.1 -U postgres -d postgres -v ON_ERROR_STOP=1
}


echo "Bootstrapping PG schema (base tables first, then drizzle_pg/000*.sql)..."
shopt -s nullglob
all=(drizzle_pg/000*.sql)
if [ "${#all[@]}" -eq 0 ]; then
  echo "ERROR: no drizzle_pg/000*.sql files found" >&2
  ls -la drizzle_pg >&2 || true
  exit 1
fi

# 1) task_events (base table; contracts/triggers assume task_id exists)
echo "  applying(base): inline public.task_events"
psql_in_ctn <<'SQL'
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.task_events (
  id BIGSERIAL PRIMARY KEY,
  kind TEXT NOT NULL,
  task_id TEXT NOT NULL,
  run_id TEXT NULL,
  actor TEXT NULL,
  ts BIGINT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb
);
SQL

# 2) tasks table next (base table; drizzle_pg contains ALTERs/views that assume it exists)
echo "  applying(base): inline public.tasks"
psql_in_ctn <<'SQL'
CREATE TABLE IF NOT EXISTS public.tasks (
  id BIGSERIAL PRIMARY KEY,
  task_id TEXT NOT NULL UNIQUE,
  title TEXT NULL,
  status TEXT NOT NULL DEFAULT 'queued',
  run_id TEXT NULL,
  actor TEXT NULL,
  claimed_by TEXT NULL,
  claimed_at BIGINT NULL,
  lease_expires_at BIGINT NULL,
  lease_epoch INT NOT NULL DEFAULT 0,
  notes TEXT NULL,
  failed_at TIMESTAMPTZ NULL,
  action_tier TEXT NOT NULL DEFAULT 'A',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()

);
SQL

# 3) apply everything else in lexical order
for f in "${all[@]}"; do
  echo "  applying: $f"
  psql_in_ctn < "$f"
done

echo "OK: PG schema bootstrapped (tables + views)."
