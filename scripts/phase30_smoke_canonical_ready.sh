#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
: "${POSTGRES_URL:?POSTGRES_URL required}"

echo "=== phase30: doctor (pretty) ==="
server/worker/phase30_db_doctor_pretty.sh

echo "=== phase30: ensure canonical-ready (run phase29 migration if needed) ==="
# If payload_jsonb missing, run the non-destructive phase29 migrator.
has_jsonb="$(psql "$POSTGRES_URL" -qtAc "select count(*)::int from information_schema.columns where table_name='task_events' and column_name='payload_jsonb'")"
if [ "${has_jsonb:-0}" -lt 1 ]; then
  echo "payload_jsonb missing -> running server/worker/phase29_db_migrate_to_phase27.sql"
  psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -f server/worker/phase29_db_migrate_to_phase27.sql
fi

echo "=== phase30: strict contract check ==="
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -f server/worker/phase30_contract_check.sql

echo "=== phase30: run deterministic worker smoke ==="
./scripts/phase28_smoke_one.sh
