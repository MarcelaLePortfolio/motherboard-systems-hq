#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_tasks_schema_prereq_evidence.txt"

{
  echo "PHASE 456 — TASKS SCHEMA PREREQUISITE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  df -h .
  echo
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo

  echo "=== CANONICAL STACK STATE ==="
  docker compose ps
  echo

  echo "=== POSTGRES: TASKS TABLE COLUMNS ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c '\d+ public.tasks' 2>&1 || true
  echo

  echo "=== POSTGRES: TASK_EVENTS TABLE COLUMNS ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c '\d+ public.task_events' 2>&1 || true
  echo

  echo "=== POSTGRES: INFORMATION_SCHEMA CHECK ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "
    SELECT table_name, column_name
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name IN ('tasks','task_events')
    ORDER BY table_name, ordinal_position;
  " 2>&1 || true
  echo

  echo "=== REPO SEARCH: lease_expires_at / heartbeat / run prereqs ==="
  grep -RniE "lease_expires_at|last_heartbeat_ts|heartbeat_age_ms|lease_fresh|lease_ttl_ms|next_run_at|claimed_by|ALTER TABLE tasks|ADD COLUMN.*lease_expires_at|ADD COLUMN.*last_heartbeat_ts" \
    drizzle_pg server sql scripts . 2>/dev/null | head -500 || true
  echo

  echo "=== REPO SEARCH: tasks bootstrap / prerequisite migrations ==="
  grep -RniE "CREATE TABLE tasks|ALTER TABLE tasks|db_bootstrap|bootstrap|phase29|phase30|phase54_bootstrap|task_events" \
    drizzle_pg server sql scripts . 2>/dev/null | head -500 || true
  echo

  echo "=== SHOW CANDIDATE MIGRATION FILES ==="
  find drizzle_pg -maxdepth 1 -type f | sort || true
  echo

  echo "=== CANONICAL POSTGRES LOGS (TAIL 120) ==="
  docker compose logs --tail 120 postgres 2>&1 || true
  echo

  echo "=== CANONICAL DASHBOARD LOGS (TAIL 120) ==="
  docker compose logs --tail 120 dashboard 2>&1 || true
  echo
} | tee "$OUT"
