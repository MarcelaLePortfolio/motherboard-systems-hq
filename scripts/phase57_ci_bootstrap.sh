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

# 1) task_events (and extensions) first
TASK_EVENTS_FILE="drizzle_pg/0001_create_task_events.sql"
if [ ! -f "$TASK_EVENTS_FILE" ]; then
  echo "ERROR: expected file missing: $TASK_EVENTS_FILE" >&2
  ls -la drizzle_pg >&2 || true
  exit 1
fi
echo "  applying(base): $TASK_EVENTS_FILE"
psql_in_ctn < "$TASK_EVENTS_FILE"

# 2) tasks table next (find the file that creates it)
TASKS_FILE="$(grep -RIl --include='000*.sql' -E 'CREATE TABLE( IF NOT EXISTS)?[[:space:]]+([[:alnum:]_]+\.)?tasks([[:space:]]|\()' drizzle_pg | LC_ALL=C sort | head -n 1 || true)"
if [ -z "${TASKS_FILE:-}" ]; then
  echo "ERROR: could not find CREATE TABLE tasks in drizzle_pg/000*.sql" >&2
  grep -RIn --include='000*.sql' -E 'CREATE TABLE' drizzle_pg >&2 || true
  exit 1
fi
echo "  applying(base): $TASKS_FILE"
psql_in_ctn < "$TASKS_FILE"

# 3) apply everything else in lexical order, skipping the two base files
for f in "${all[@]}"; do
  if [ "$f" = "$TASK_EVENTS_FILE" ] || [ "$f" = "$TASKS_FILE" ]; then
    continue
  fi
  echo "  applying: $f"
  psql_in_ctn < "$f"
done

echo "OK: PG schema bootstrapped (tables + views)."
