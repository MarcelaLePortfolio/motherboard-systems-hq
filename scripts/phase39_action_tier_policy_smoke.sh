#!/usr/bin/env bash
set -euo pipefail

# Deterministic smoke: read-only validation for Phase 39 action_tier policy
# - discovers postgres container
# - runs validation query (fed from host file; no in-container path assumptions)
# - fails if any observed kind is unmapped (fail-closed)

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

PGC="$(docker ps --format '{{.Names}}' | awk '
  /^motherboard_systems_hq-postgres-1$/ {print; found=1; exit}
  END { if (!found) exit 0 }
' || true)"

if [[ -z "${PGC:-}" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n 1 || true)"
fi

: "${PGC:?ERROR: postgres container not found (is the stack up?)}"

echo "PGC=$PGC"
echo "=== Phase 39: action_tier policy (read-only) validate ==="

OUT="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f - < sql/policy/action_tier_validate.sql
)"

echo "$OUT"

UNMAPPED_LINE="$(printf "%s\n" "$OUT" | rg -n 'PHASE39_UNMAPPED_COUNT=' | tail -n 1 | sed -E 's/^[0-9]+://')"
UNMAPPED_COUNT="$(printf "%s" "$UNMAPPED_LINE" | sed -E 's/.*PHASE39_UNMAPPED_COUNT=([0-9]+).*/\1/')"

if [[ -z "${UNMAPPED_COUNT:-}" ]] || ! [[ "$UNMAPPED_COUNT" =~ ^[0-9]+$ ]]; then
  echo "ERROR: could not parse PHASE39_UNMAPPED_COUNT from output." >&2
  exit 2
fi

echo "unmapped_count=$UNMAPPED_COUNT"

if [[ "$UNMAPPED_COUNT" != "0" ]]; then
  echo "FAIL: action_tier policy is missing mappings for observed kinds (fail-closed)." >&2
  echo "Action: add missing kinds to sql/policy/action_tier_policy.sql AND sql/policy/action_tier_validate.sql policy list." >&2
  exit 1
fi

echo "OK: Phase 39 action_tier policy validation passed (read-only, deterministic)."
echo "STOPPING POINT: Phase 39 smoke is green; next natural stop is opening the PR."
