#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_6_tasks_route_minimum_schema_and_verify.txt"

mkdir -p docs

{
  echo "PHASE 468.6 — ASSERT TASKS ROUTE MINIMUM SCHEMA + VERIFY"
  echo "========================================================"
  echo
  echo "OBJECTIVE"
  echo "- Fix only the proven white-page root cause corridor."
  echo "- Add the minimum route-required task columns missing from the live tasks table."
  echo "- Do not broaden scope."
  echo

  echo "STEP 1 — Apply minimum safe schema alignment"
  docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS agent TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS source TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS trace_id TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS error TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS meta JSONB;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
SQL
  echo

  echo "STEP 2 — Restart dashboard container"
  docker compose restart dashboard 2>&1 || true
  echo

  echo "STEP 3 — Wait for service stabilization"
  sleep 4
  echo "Waited 4 seconds"
  echo

  echo "STEP 4 — Verify /api/tasks route"
  echo "--- GET /api/tasks ---"
  curl -i --max-time 5 http://localhost:3000/api/tasks 2>&1 || true
  echo

  echo "STEP 5 — Verify dashboard entrypoint"
  echo "--- GET /dashboard.html ---"
  curl -i --max-time 5 http://localhost:3000/dashboard.html 2>&1 || true
  echo

  echo "STEP 6 — Verify bundle"
  echo "--- GET /bundle.js ---"
  curl -i --max-time 5 http://localhost:3000/bundle.js 2>&1 || true
  echo

  echo "STEP 7 — Tail recent dashboard logs"
  docker compose logs --tail=120 dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  API_OK=0
  DASH_OK=0
  TITLE_ERR=0

  if curl -s --max-time 5 http://localhost:3000/api/tasks >/dev/null 2>&1; then
    API_OK=1
  fi

  if curl -s --max-time 5 http://localhost:3000/dashboard.html >/dev/null 2>&1; then
    DASH_OK=1
  fi

  if docker compose logs --tail=120 dashboard 2>&1 | rg -q 'column "title" does not exist'; then
    TITLE_ERR=1
  fi

  if [ "$API_OK" -eq 1 ] && [ "$DASH_OK" -eq 1 ] && [ "$TITLE_ERR" -eq 0 ]; then
    echo "CLASSIFICATION: TASKS_ROUTE_SCHEMA_ALIGNED"
  else
    echo "CLASSIFICATION: FURTHER_SCHEMA_OR_BOOT_REVIEW_REQUIRED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- If aligned: re-open browser and test refresh."
  echo "- If not aligned: inspect remaining route-selected columns only."
} > "$OUT"

echo "Wrote $OUT"
