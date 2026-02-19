#!/usr/bin/env bash
set -euo pipefail

PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' || true)"
: "${PGC:?ERROR: postgres container not found (expected motherboard_systems_hq-postgres-1)}"

docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 < sql/phase41_scenario_matrix_run_view.sql
