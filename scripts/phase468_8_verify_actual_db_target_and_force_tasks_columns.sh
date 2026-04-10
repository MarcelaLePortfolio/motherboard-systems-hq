#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_8_verify_actual_db_target_and_force_tasks_columns.txt"

mkdir -p docs

{
  echo "PHASE 468.8 — VERIFY ACTUAL DB TARGET + FORCE TASKS COLUMNS"
  echo "==========================================================="
  echo
  echo "STEP 1 — Confirm dashboard DB target"
  docker compose exec -T dashboard sh -lc 'printf "DATABASE_URL=%s\n" "$DATABASE_URL"' 2>&1 || true
  echo

  echo "STEP 2 — Show tasks schema from postgres container"
  docker compose exec -T postgres psql -U postgres -d postgres -c "\d+ public.tasks" 2>&1 || true
  echo

  echo "STEP 3 — Force required columns onto public.tasks"
  docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS agent TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS source TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS trace_id TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS error TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS meta JSONB;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'tasks'
ORDER BY ordinal_position;
SQL
  echo

  echo "STEP 4 — Restart dashboard"
  docker compose restart dashboard 2>&1 || true
  echo

  echo "STEP 5 — Wait for boot"
  sleep 5
  echo "Waited 5 seconds"
  echo

  echo "STEP 6 — Probe api/tasks after forced schema alignment"
  curl -i --max-time 5 http://localhost:3000/api/tasks 2>&1 || true
  echo

  echo "STEP 7 — Recent dashboard logs"
  docker compose logs --tail=120 dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if docker compose logs --tail=120 dashboard 2>&1 | rg -q 'column "title" does not exist'; then
    echo "CLASSIFICATION: DASHBOARD_NOT_READING_EXPECTED_TABLE_OR_DB"
  else
    echo "CLASSIFICATION: TASKS_COLUMNS_FORCED_ON_PUBLIC_TABLE"
  fi
} > "$OUT"

echo "Wrote $OUT"
