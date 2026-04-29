#!/usr/bin/env bash

set -euo pipefail

echo "=== BOOTSTRAP SCHEMA GUARD START ==="

# ensure DATABASE_URL exists
if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: DATABASE_URL not set"
  exit 1
fi

# wait for postgres
until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  echo "waiting for postgres..."
  sleep 2
done

echo "postgres is ready"

# run bootstrap (idempotent)
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f docker-entrypoint-initdb.d/00_phase54_bootstrap.sql

echo "schema bootstrap complete"
echo "=== BOOTSTRAP SCHEMA GUARD END ==="
