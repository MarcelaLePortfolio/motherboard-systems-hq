#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_5_tasks_route_query_and_schema.txt"
ROUTE="server/routes/api-tasks-postgres.mjs"

mkdir -p docs

{
  echo "PHASE 468.5 — TASKS ROUTE QUERY + SCHEMA PROBE"
  echo "=============================================="
  echo
  echo "TARGET ROUTE: $ROUTE"
  echo

  echo "STEP 1 — Route file presence"
  [ -f "$ROUTE" ] && echo "OK: route file present" || echo "FAIL: route file missing"
  echo

  echo "STEP 2 — Extract task query surface"
  sed -n '1,220p' "$ROUTE" 2>&1 || true
  echo

  echo "STEP 3 — High-signal query lines"
  rg -n "select|from tasks|title|agent|status|notes|trace_id|source|error|meta|created_at|updated_at" "$ROUTE" 2>&1 || true
  echo

  echo "STEP 4 — Live tasks table schema"
  docker compose exec -T postgres psql -U postgres -d postgres -c "\d+ tasks" 2>&1 || true
  echo

  echo "STEP 5 — Information schema snapshot"
  docker compose exec -T postgres psql -U postgres -d postgres -c "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'tasks' ORDER BY ordinal_position;" 2>&1 || true
  echo

  echo "STEP 6 — Decision target"
  echo "- Compare exact SELECT fields in api-tasks-postgres.mjs against live tasks schema."
  echo "- Next mutation must add ONLY the missing columns required by the route."
} > "$OUT"

echo "Wrote $OUT"
