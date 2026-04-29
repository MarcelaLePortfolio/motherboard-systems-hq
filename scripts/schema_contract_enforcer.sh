#!/usr/bin/env bash
set -euo pipefail

echo "=== SCHEMA CONTRACT ENFORCER START ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  echo "waiting for postgres..."
  sleep 2
done

echo "postgres ready"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f docker-entrypoint-initdb.d/00_phase54_bootstrap.sql

echo "bootstrap applied"

# ---- CONTRACT DEFINITION (SOURCE OF TRUTH) ----
expected_tables=(
  "tasks"
  "task_events"
  "worker_heartbeats"
)

check_table () {
  psql "$DATABASE_URL" -tAc "SELECT to_regclass('public.$1') IS NOT NULL;"
}

echo "validating schema contract..."

for t in "${expected_tables[@]}"; do
  exists=$(check_table "$t")
  if [ "$exists" != "t" ]; then
    echo "❌ CONTRACT VIOLATION: missing table $t"
    exit 1
  fi
done

# ---- COLUMN CONTRACTS ----

validate_columns () {
  table=$1
  shift
  for col in "$@"; do
    exists=$(psql "$DATABASE_URL" -tAc "
      SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public'
        AND table_name='$table'
        AND column_name='$col'
      );
    ")
    if [ "$exists" != "t" ]; then
      echo "❌ CONTRACT VIOLATION: $table missing column $col"
      exit 1
    fi
  done
}

validate_columns "tasks" "id" "task_id" "status" "kind" "payload" "created_at" "run_id" "claimed_by" "attempts"
validate_columns "task_events" "id" "task_id" "kind" "actor" "ts"
validate_columns "worker_heartbeats" "owner" "last_seen_at"

echo "schema contract satisfied"

# ---- HARD GUARANTEE OUTPUT ----
psql "$DATABASE_URL" -tAc "
SELECT 'tasks='||count(*) FROM tasks;
SELECT 'task_events='||count(*) FROM task_events;
SELECT 'heartbeats='||count(*) FROM worker_heartbeats;
"

echo "=== SCHEMA CONTRACT ENFORCER PASS ==="
