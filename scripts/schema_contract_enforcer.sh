#!/usr/bin/env bash
set -euo pipefail

echo "=== SCHEMA VERSION + CONTRACT ENFORCER START ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  echo "waiting for postgres..."
  sleep 2
done

echo "postgres ready"

BOOTSTRAP_FILE="docker-entrypoint-initdb.d/00_phase54_bootstrap.sql"
EXPECTED_VERSION=$(shasum -a 256 "$BOOTSTRAP_FILE" | awk '{print $1}')

echo "expected schema version: $EXPECTED_VERSION"

# ensure meta table exists
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS schema_meta (
  key text PRIMARY KEY,
  value text
);
SQL

STORED_VERSION=$(psql "$DATABASE_URL" -tAc "SELECT value FROM schema_meta WHERE key='schema_version'")

echo "stored schema version: ${STORED_VERSION:-NULL}"

# drift detection / self-heal
if [ -z "$STORED_VERSION" ] || [ "$STORED_VERSION" != "$EXPECTED_VERSION" ]; then
  echo "⚠️ schema drift detected OR missing version → running bootstrap"

  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$BOOTSTRAP_FILE"

  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
INSERT INTO schema_meta(key, value)
VALUES ('schema_version', '$EXPECTED_VERSION')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
SQL

  echo "schema version updated"
else
  echo "schema version matches"
fi

# ---- CONTRACT VALIDATION ----

validate_table () {
  local t=$1
  local exists
  exists=$(psql "$DATABASE_URL" -tAc "SELECT to_regclass('public.$t') IS NOT NULL;")
  if [ "$exists" != "t" ]; then
    echo "❌ CONTRACT VIOLATION: missing table $t"
    exit 1
  fi
}

validate_column () {
  local table=$1
  local col=$2
  local exists
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
}

echo "validating schema contract..."

validate_table "tasks"
validate_table "task_events"
validate_table "worker_heartbeats"

validate_column "tasks" "id"
validate_column "tasks" "task_id"
validate_column "tasks" "status"
validate_column "tasks" "kind"
validate_column "tasks" "payload"
validate_column "tasks" "created_at"
validate_column "tasks" "run_id"
validate_column "tasks" "claimed_by"
validate_column "tasks" "attempts"

validate_column "task_events" "id"
validate_column "task_events" "task_id"
validate_column "task_events" "kind"
validate_column "task_events" "actor"
validate_column "task_events" "ts"

validate_column "worker_heartbeats" "owner"
validate_column "worker_heartbeats" "last_seen_at"

echo "schema contract satisfied"

echo "=== SCHEMA VERSION + CONTRACT PASS ==="
