#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

# Robust postgres container detection (works across compose project name changes)
PGC="$(
  docker ps --format '{{.Names}}\t{{.Image}}' \
  | awk -F'\t' '
      tolower($2) ~ /(postgres|postgis)/ && tolower($1) ~ /(postgres|db)/ { print $1; exit }
    '
)"

if [[ -z "${PGC:-}" ]]; then
  echo "ERROR: could not find a running postgres container." >&2
  echo "HINT: run: docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | sed -n '1,80p'" >&2
  exit 2
fi

echo "PGC=$PGC"

# Capture authoritative run_view definition (as Postgres sees it)
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At <<'SQL' \
  | sed 's/[[:space:]]\+$//' \
  > PHASE37_RUN_VIEW_DEFINITION.sql
-- Phase 37.0 planning artifact: authoritative run_view SQL as Postgres sees it
SELECT pg_get_viewdef('public.run_view'::regclass, true) || ';';
SQL

# Capture run_view columns (positional) for provenance templating
tmp_cols="$(mktemp)"
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At -F '|' <<'SQL' > "$tmp_cols"
SELECT ordinal_position, column_name
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='run_view'
ORDER BY ordinal_position;
SQL

if [[ ! -s "$tmp_cols" ]]; then
  echo "ERROR: information_schema returned 0 run_view columns. Does public.run_view exist?" >&2
  rm -f "$tmp_cols"
  exit 2
fi

# Regenerate provenance matrix doc (full replace)
cat > PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md <<'MD'
# Phase 37 — run_view Provenance Matrix (Planning Only)

## How to use
Fill one section per `run_view` column. Keep everything SQL-traceable.

Canonical ordering key for “latest” semantics (unless column specifies otherwise):
- `task_events.ts` ASC
- tie-breaker: `task_events.id` ASC

## References
- `PHASE37_RUN_VIEW_DEFINITION.sql` (authoritative view definition as captured from Postgres)
- `PHASE37_RUN_PROJECTION_CONTRACT.md` (contract + inventory)

---

MD

awk -F'|' '
{
  col=$2;
  printf "## %s\n- Source(s):\n- Rule (SQL):\n- Latest semantics (by canonical ordering):\n- Nullability semantics:\n- Stability requirement:\n- Notes:\n\n", col;
}
' "$tmp_cols" >> PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md

rm -f "$tmp_cols"

echo "Wrote:"
echo "  - PHASE37_RUN_VIEW_DEFINITION.sql"
echo "  - PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md"
