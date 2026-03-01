#!/usr/bin/env bash
set -euo pipefail

# Requires POSTGRES_URL (or DATABASE_URL) to be set by the harness/overrides.
DB_URL="${POSTGRES_URL:-${DATABASE_URL:-}}"
if [[ -z "${DB_URL}" ]]; then
  echo "ERROR: POSTGRES_URL (or DATABASE_URL) is required for Phase 55 invariant." >&2
  exit 2
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "ERROR: psql not found in PATH." >&2
  exit 2
fi

psql "${DB_URL}" -v ON_ERROR_STOP=1 -f "scripts/sql/invariants/phase55_terminal_event_precedence.sql" >/dev/null
echo "OK: Phase 55 terminal_event precedence invariant clean."
