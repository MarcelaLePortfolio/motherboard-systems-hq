#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase456_apply_tasks_prereqs_and_repair_run_view.txt"

{
  echo "PHASE 456 — APPLY TASKS PREREQS AND REPAIR RUN_VIEW"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo
  df -h .
  echo

  echo "=== CANONICAL STACK STATE ==="
  docker compose ps
  echo

  echo "=== VERIFY REQUIRED MIGRATION FILES ==="
  ls -l \
    drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql \
    drizzle_pg/0007_phase35_lease_epoch.sql \
    drizzle_pg/0007_phase36_1_run_view.sql \
    drizzle_pg/0007_phase36_2_run_view_contract.sql
  echo

  echo "=== TASKS COLUMNS BEFORE ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name='tasks'
      AND column_name IN ('claimed_by','claimed_at','lease_expires_at','lease_epoch')
    ORDER BY column_name;
  "
  echo

  echo "=== RUN_VIEW BEFORE ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -t -A -c "
    SELECT COUNT(*) FROM pg_views WHERE schemaname='public' AND viewname='run_view';
  "
  echo

  echo "=== APPLY PREREQ MIGRATION: PHASE34 LEASE / HEARTBEAT RECLAIM ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -v ON_ERROR_STOP=1 \
    < drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql
  echo

  echo "=== APPLY PREREQ MIGRATION: PHASE35 LEASE EPOCH ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -v ON_ERROR_STOP=1 \
    < drizzle_pg/0007_phase35_lease_epoch.sql
  echo

  echo "=== TASKS COLUMNS AFTER PREREQS ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name='tasks'
      AND column_name IN ('claimed_by','claimed_at','lease_expires_at','lease_epoch')
    ORDER BY column_name;
  "
  echo

  echo "=== APPLY RUN_VIEW MIGRATION ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -v ON_ERROR_STOP=1 \
    < drizzle_pg/0007_phase36_1_run_view.sql
  echo

  echo "=== APPLY RUN_VIEW CONTRACT MIGRATION ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -v ON_ERROR_STOP=1 \
    < drizzle_pg/0007_phase36_2_run_view_contract.sql
  echo

  echo "=== RUN_VIEW AFTER ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "
    SELECT schemaname, viewname
    FROM pg_views
    WHERE schemaname='public' AND viewname='run_view';
  "
  echo

  echo "=== RUN_VIEW SAMPLE ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "
    SELECT *
    FROM run_view
    ORDER BY last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST, run_id DESC
    LIMIT 5;
  " || true
  echo

  echo "=== API PROBE: /api/runs ==="
  curl -sS --max-time 15 "http://localhost:8080/api/runs?limit=5"
  echo
  echo

  echo "=== DASHBOARD LOGS AFTER REPAIR (TAIL 120) ==="
  docker compose logs --tail 120 dashboard 2>&1 || true
  echo

  echo "=== POSTGRES LOGS AFTER REPAIR (TAIL 120) ==="
  docker compose logs --tail 120 postgres 2>&1 || true
  echo
} | tee "$OUT"
