#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_tasks_schema_migration_path.txt"
POSTGRES_CID="$(docker compose ps -q postgres || true)"

{
  echo "PHASE 488 — TRACE TASKS SCHEMA MIGRATION PATH"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] CURRENT LIVE tasks COLUMNS"
} > "$REPORT"

if [ -n "${POSTGRES_CID}" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select column_name, data_type from information_schema.columns where table_schema='public' and table_name='tasks' order by ordinal_position;" \
    >> "$REPORT" 2>&1 || true
else
  echo "NO_POSTGRES_CONTAINER" >> "$REPORT"
fi

{
  echo
  echo "[2] SEARCH: TASKS TABLE CREATION / ALTER PATH"
  grep -RniE 'create table.*tasks|alter table.*tasks|available_at|locked_by|lock_expires_at|attempts|max_attempts|next_run_at|claimed_by|claimed_at|lease_expires_at|lease_epoch|completed_at|failed_at|last_error|actor' \
    server scripts sql . 2>/dev/null || true
  echo

  echo "[3] WORKER SQL FAMILY SNAPSHOT"
  for f in \
    server/worker/phase27_claim_one.sql \
    server/worker/phase27_mark_success.sql \
    server/worker/phase27_mark_failure.sql \
    server/worker/phase28_claim_one.sql \
    server/worker/phase28_mark_success.sql \
    server/worker/phase28_mark_failure.sql \
    server/worker/phase32_claim_one.sql \
    server/worker/phase32_mark_success.sql \
    server/worker/phase32_mark_failure.sql \
    server/worker/phase34_claim_one_pg.sql \
    server/worker/phase34_mark_success_pg.sql \
    server/worker/phase34_mark_failure_pg.sql \
    server/worker/phase35_claim_one_pg.sql \
    server/worker/phase35_mark_success_pg.sql \
    server/worker/phase35_mark_failure_pg.sql
  do
    if [ -f "$f" ]; then
      echo "===== $f ====="
      sed -n '1,200p' "$f"
      echo
    fi
  done

  echo "[4] SEARCH: DB BOOTSTRAP / MIGRATION ENTRYPOINTS"
  grep -RniE 'db_bootstrap|migrate|bootstrap.*tasks|schema.*tasks|task_events|run_view|phase29_db_migrate_to_phase27|phase3[245]|phase2[789]' \
    server scripts package*.json docker-compose* . 2>/dev/null || true
  echo

  echo "[5] VERDICT TARGET"
  echo "- Identify the canonical tasks schema expected by the worker family"
  echo "- Identify the migration/bootstrap file that should have introduced missing task columns"
  echo "- Decide next smallest fix: run migration vs wire alternate worker family"
  echo

  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,360p' "$REPORT"
