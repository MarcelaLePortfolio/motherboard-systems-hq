#!/usr/bin/env bash
set -euo pipefail

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

# Preflight: ensure a kind-like source exists
PICKED_COUNT="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -qAt <<'SQL'
\pset pager off
\set ON_ERROR_STOP on
WITH candidates AS (
  SELECT table_schema, table_name, column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name IN ('kind','event_kind','task_kind','type')
),
picked AS (
  SELECT table_schema, table_name, column_name
  FROM candidates
  WHERE (table_name ILIKE '%task%event%' OR table_name ILIKE '%task_events%')
  ORDER BY
    (table_name ILIKE '%task_events%') DESC,
    (table_name ILIKE '%event%') DESC,
    (column_name = 'kind') DESC,
    table_schema,
    table_name
  LIMIT 1
)
SELECT COUNT(*)::text FROM picked;
SQL
)"
PICKED_COUNT="$(printf "%s" "$PICKED_COUNT" | tr -d '\r' | tr -d ' ')"
if [[ "$PICKED_COUNT" != "1" ]]; then
  echo "FAIL: could not discover kind-like source column for validation." >&2
  exit 2
fi

OUT="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f - < sql/policy/action_tier_validate.sql
)"
echo "$OUT"

UNMAPPED_LINE="$(printf "%s\n" "$OUT" | rg 'PHASE39_UNMAPPED_COUNT=' | tail -n 1)"
UNMAPPED_COUNT="$(printf "%s" "$UNMAPPED_LINE" | sed -E 's/.*PHASE39_UNMAPPED_COUNT=([0-9]+).*/\1/' | tr -d '\r' | tr -d ' ')"

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
echo "STOPPING POINT: smoke is green; next natural stop is opening the PR (you’re 1 step away)."
