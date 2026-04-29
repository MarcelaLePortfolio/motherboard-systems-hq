#!/usr/bin/env bash
set -euo pipefail

echo "=== MIGRATION GRAPH + SAFE SCHEMA EVOLUTION ENGINE ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  echo "waiting for postgres..."
  sleep 2
done

echo "postgres ready"

BOOTSTRAP_FILE="docker-entrypoint-initdb.d/00_phase54_bootstrap.sql"

# -------------------------
# MIGRATION GRAPH TABLE
# -------------------------
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS schema_migrations (
  id bigserial PRIMARY KEY,
  version text UNIQUE NOT NULL,
  applied_at timestamptz DEFAULT now(),
  checksum text NOT NULL
);
SQL

# -------------------------
# MIGRATION DEFINITIONS (GRAPH)
# -------------------------
declare -A MIGRATIONS

# baseline snapshot
MIGRATIONS["000_base"]="$BOOTSTRAP_FILE"

# future-safe evolution example nodes (idempotent reapply-safe style)
MIGRATIONS["001_worker_heartbeats"]=""
MIGRATIONS["002_task_events_contract"]=""
MIGRATIONS["003_task_core_contract"]=""

apply_migration () {
  local version=$1
  local file=$2

  existing=$(psql "$DATABASE_URL" -tAc "SELECT 1 FROM schema_migrations WHERE version='$version'")

  if [ "$existing" = "1" ]; then
    echo "✔ migration already applied: $version"
    return
  fi

  echo "→ applying migration: $version"

  if [ -n "$file" ]; then
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$file"
  fi

  checksum=$(echo "${version}-${file}" | shasum -a 256 | awk '{print $1}')

  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "
    INSERT INTO schema_migrations(version, checksum)
    VALUES ('$version', '$checksum')
  "

  echo "✔ migration committed: $version"
}

# -------------------------
# APPLY GRAPH IN ORDER
# -------------------------
apply_migration "000_base" "$BOOTSTRAP_FILE"

apply_migration "001_worker_heartbeats" ""
apply_migration "002_task_events_contract" ""
apply_migration "003_task_core_contract" ""

# -------------------------
# CONTRACT VALIDATION (FINAL GATE)
# -------------------------
echo "validating final schema state..."

validate_table () {
  local t=$1
  local exists
  exists=$(psql "$DATABASE_URL" -tAc "SELECT to_regclass('public.$t') IS NOT NULL;")
  if [ "$exists" != "t" ]; then
    echo "❌ SCHEMA FAILURE: missing table $t"
    exit 1
  fi
}

validate_table "tasks"
validate_table "task_events"
validate_table "worker_heartbeats"

echo "schema evolution graph complete"
echo "=== MIGRATION ENGINE PASS ==="
