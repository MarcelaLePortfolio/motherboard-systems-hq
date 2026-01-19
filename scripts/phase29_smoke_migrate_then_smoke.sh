#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
: "${POSTGRES_URL:?POSTGRES_URL required}"

echo "=== phase29: doctor BEFORE ==="
server/worker/phase29_db_doctor.sh

echo "=== phase29: migrate DB to phase27-ish contract (non-destructive) ==="
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -f server/worker/phase29_db_migrate_to_phase27.sql

echo "=== phase29: doctor AFTER ==="
server/worker/phase29_db_doctor.sh

echo "=== phase29: run deterministic smoke (should still pass) ==="
./scripts/phase28_smoke_one.sh
