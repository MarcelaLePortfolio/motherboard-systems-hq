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

echo "Bootstrapping PG schema (drizzle_pg/000*.sql in order)..."
shopt -s nullglob
files=(drizzle_pg/000*.sql)
if [ "${#files[@]}" -eq 0 ]; then
  echo "ERROR: no drizzle_pg/000*.sql files found" >&2
  ls -la drizzle_pg >&2 || true
  exit 1
fi

for f in "${files[@]}"; do
  echo "  applying: $f"
  psql_in_ctn < "$f"
done

echo "OK: PG schema bootstrapped (tables + views)."
