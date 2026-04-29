#!/usr/bin/env bash
set -euo pipefail

echo "=== SCHEMA GUARD (UNIFIED) ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

echo "waiting for postgres..."
until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  sleep 2
done

echo "postgres ready"

echo "running bootstrap (idempotent)"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f docker-entrypoint-initdb.d/00_phase54_bootstrap.sql

echo "running migration engine"
bash scripts/schema_migration_engine.sh

echo "running contract validation"
bash scripts/schema_contract_enforcer.sh

echo "schema guard complete"
