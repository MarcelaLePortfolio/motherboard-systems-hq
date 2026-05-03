#!/usr/bin/env bash
set -euo pipefail

echo "=== WAIT FOR SCHEMA READINESS ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

until psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -tAc "
SELECT
  (to_regclass('public.tasks') IS NOT NULL)::int +
  (to_regclass('public.task_events') IS NOT NULL)::int +
  (to_regclass('public.worker_heartbeats') IS NOT NULL)::int
" | grep -q "3"
do
  echo "schema not ready... retrying"
  sleep 2
done

echo "schema ready"
