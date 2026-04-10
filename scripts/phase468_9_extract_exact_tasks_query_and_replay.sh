#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_9_extract_exact_tasks_query_and_replay.txt"
ROUTE="server/routes/api-tasks-postgres.mjs"

mkdir -p docs

{
  echo "PHASE 468.9 — EXTRACT EXACT TASKS QUERY + REPLAY"
  echo "==============================================="
  echo
  echo "TARGET ROUTE: $ROUTE"
  echo

  echo "STEP 1 — Exact route excerpt around failing query"
  nl -ba "$ROUTE" | sed -n '1,220p' 2>&1 || true
  echo

  echo "STEP 2 — High-signal query lines"
  rg -n -C 8 "SELECT|FROM|ORDER BY|LIMIT|title|agent|status|notes|trace_id|source|error|meta|created_at|updated_at|pool\.query|query\(" "$ROUTE" 2>&1 || true
  echo

  echo "STEP 3 — Direct table smoke query in postgres"
  docker compose exec -T postgres psql -U postgres -d postgres -c "SELECT id, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at FROM public.tasks ORDER BY created_at DESC NULLS LAST LIMIT 3;" 2>&1 || true
  echo

  echo "STEP 4 — Search for alternate tasks relations"
  docker compose exec -T postgres psql -U postgres -d postgres -c "SELECT schemaname, tablename FROM pg_tables WHERE tablename = 'tasks' ORDER BY schemaname, tablename;" 2>&1 || true
  echo
  docker compose exec -T postgres psql -U postgres -d postgres -c "SELECT schemaname, viewname FROM pg_views WHERE viewname = 'tasks' ORDER BY schemaname, viewname;" 2>&1 || true
  echo

  echo "STEP 5 — Search path + current DB"
  docker compose exec -T postgres psql -U postgres -d postgres -c "SHOW search_path;" 2>&1 || true
  echo
  docker compose exec -T postgres psql -U postgres -d postgres -c "SELECT current_database(), current_schema();" 2>&1 || true
  echo

  echo "STEP 6 — Dashboard env DB target"
  docker compose exec -T dashboard sh -lc 'printf "DATABASE_URL=%s\nPGDATABASE=%s\nPGHOST=%s\nPGPORT=%s\nPGUSER=%s\n" "${DATABASE_URL:-}" "${PGDATABASE:-}" "${PGHOST:-}" "${PGPORT:-}" "${PGUSER:-}"' 2>&1 || true
  echo

  echo "STEP 7 — Classification target"
  echo "- If direct SELECT succeeds but route still fails, the route query text or relation binding is wrong."
  echo "- If alternate tasks relation exists, the route may be resolving the wrong relation."
  echo "- Next mutation must target the exact failing SQL line only."
} > "$OUT"

echo "Wrote $OUT"
