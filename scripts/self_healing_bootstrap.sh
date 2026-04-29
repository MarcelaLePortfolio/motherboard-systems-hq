#!/usr/bin/env bash
set -euo pipefail

echo "=== SELF-HEALING BOOTSTRAP START ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

# wait for postgres
until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  echo "waiting for postgres..."
  sleep 2
done

echo "postgres ready"

# ensure schema exists (run bootstrap every time safely)
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f docker-entrypoint-initdb.d/00_phase54_bootstrap.sql

echo "bootstrap executed"

# verify + repair loop
attempt=0
max_attempts=10

until [ "$attempt" -ge "$max_attempts" ]
do
  missing=$(
    psql "$DATABASE_URL" -tAc "
      SELECT
        CASE WHEN to_regclass('public.tasks') IS NULL THEN 1 ELSE 0 END +
        CASE WHEN to_regclass('public.task_events') IS NULL THEN 1 ELSE 0 END +
        CASE WHEN to_regclass('public.worker_heartbeats') IS NULL THEN 1 ELSE 0 END
    "
  )

  if [ "$missing" = "0" ]; then
    echo "schema verified"
    exit 0
  fi

  echo "schema incomplete (missing=$missing) retrying bootstrap..."
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f docker-entrypoint-initdb.d/00_phase54_bootstrap.sql || true

  attempt=$((attempt+1))
  sleep 2
done

echo "FAILED: schema could not be stabilized"
exit 1
