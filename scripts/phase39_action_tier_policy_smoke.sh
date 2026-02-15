#!/usr/bin/env bash
set -euo pipefail

# Deterministic smoke: read-only validation for Phase 39 action_tier policy
# - discovers postgres container
# - runs validation query
# - fails if any observed kind is unmapped (fail-closed)

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

PGC="$(docker ps --format '{{.Names}}' | awk '
  /^motherboard_systems_hq-postgres-1$/ {print; found=1; exit}
  END { if (!found) exit 0 }
' || true)"

if [[ -z "${PGC:-}" ]]; then
  # fallback: first container name containing "postgres" in this project
  PGC="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n 1 || true)"
fi

: "${PGC:?ERROR: postgres container not found (is the stack up?)}"

echo "PGC=$PGC"
echo "=== Phase 39: action_tier policy (read-only) validate ==="

# 1) Run the mapping output (for visibility) and capture unmapped_count
OUT="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -qAt <<'SQL'
\pset pager off
\set ON_ERROR_STOP on

-- Emit mapping table (observed kinds with tiers)
\i sql/policy/action_tier_validate.sql

-- Recompute unmapped_count in a single scalar for assertion (dynamic discovery)
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
),
policy AS (
  SELECT kind
  FROM (
    VALUES
      ('task.created'),
      ('task.running'),
      ('task.completed'),
      ('task.failed'),
      ('task.canceled'),
      ('task.cancelled')
  ) p(kind)
),
dyn AS (
  SELECT format(
    $fmt$
    WITH observed AS (
      SELECT DISTINCT %1$I AS kind
      FROM %2$I.%3$I
      WHERE %1$I IS NOT NULL
    ),
    unmapped AS (
      SELECT o.kind
      FROM observed o
      LEFT JOIN policy p ON p.kind = o.kind
      WHERE p.kind IS NULL
    )
    SELECT COUNT(*)::text FROM unmapped;
    $fmt$,
    (SELECT column_name FROM picked),
    (SELECT table_schema FROM picked),
    (SELECT table_name FROM picked)
  ) AS sql
)
SELECT sql FROM dyn;
SQL
)"

# The last line should be the scalar count (because dyn outputs one line).
UNMAPPED_COUNT="$(printf "%s\n" "$OUT" | tail -n 1 | tr -d '\r' | tr -d ' ')"

if [[ -z "${UNMAPPED_COUNT:-}" ]] || ! [[ "$UNMAPPED_COUNT" =~ ^[0-9]+$ ]]; then
  echo "ERROR: could not parse unmapped_count from output." >&2
  echo "---- raw tail ----" >&2
  printf "%s\n" "$OUT" | tail -n 30 >&2
  exit 2
fi

echo "unmapped_count=$UNMAPPED_COUNT"

if [[ "$UNMAPPED_COUNT" != "0" ]]; then
  echo "FAIL: action_tier policy is missing mappings for observed kinds (fail-closed)." >&2
  echo "Action: add the missing kinds to sql/policy/action_tier_policy.sql and action_tier_validate.sql policy list." >&2
  exit 1
fi

echo "OK: Phase 39 action_tier policy validation passed (read-only, deterministic)."
