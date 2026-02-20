#!/usr/bin/env bash
set -euo pipefail

# Phase 47: fail-fast smoke for decision correctness (claim/lease/reclaim)
# - SQL-first invariants
# - minimal noise output
# - exits non-zero on ANY invariant failure

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Find postgres container (supports common naming)
PGC="$(docker ps --format '{{.Names}}' | grep -E '(^|-)postgres-1$' | head -n1 || true)"
if [[ -z "${PGC:-}" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n1 || true)"
fi
: "${PGC:?ERROR: postgres container not found (is docker compose up?)}"

SQL_PATH_IN_REPO="server/sql/phase47_decision_correctness_invariants.sql"
[[ -f "$SQL_PATH_IN_REPO" ]] || { echo "ERROR: missing $SQL_PATH_IN_REPO" >&2; exit 1; }

# Execute invariants inside postgres container with ON_ERROR_STOP
docker exec -i "$PGC" sh -lc "psql -v ON_ERROR_STOP=1 -f - " < "$SQL_PATH_IN_REPO" \
| sed -n '1,120p'

echo "OK: Phase 47 smoke passed."
