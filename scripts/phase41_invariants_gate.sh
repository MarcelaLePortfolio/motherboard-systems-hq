#!/usr/bin/env bash
set -euo pipefail

PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' || true)"
: "${PGC:?ERROR: postgres container not found (expected motherboard_systems_hq-postgres-1)}"

TMP="$(mktemp)"
cleanup(){ rm -f "$TMP"; }
trap cleanup EXIT

docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 < sql/phase41_invariants_run_view.sql > "$TMP"

if [ -s "$TMP" ]; then
  cat "$TMP"
  echo
  echo "ERROR: Phase 41 invariant violations detected. Revert required."
  exit 41
fi

echo "OK: Phase 41 invariants clean."
