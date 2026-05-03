#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_run_view_schema_evidence.txt"

{
  echo "PHASE 456 — RUN_VIEW SCHEMA EVIDENCE"
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

  echo "=== CANONICAL COMPOSE STATE ==="
  docker compose ps || true
  echo

  echo "=== SEARCH: run_view / runs / schema bootstrap ==="
  grep -RniE "run_view|CREATE VIEW run_view|create view run_view|CREATE OR REPLACE VIEW run_view|ensure.*run|bootstrap.*run|schema.*run|migration.*run" \
    server src scripts app routes sql db . 2>/dev/null | head -500 || true
  echo

  echo "=== SEARCH: DB BOOTSTRAP / MIGRATION ENTRYPOINTS ==="
  grep -RniE "bootstrap|migrate|migration|schema|db_bootstrap|ensure.*tasks|ensure.*run|run_view" \
    server src scripts app routes sql db . 2>/dev/null | head -500 || true
  echo

  echo "=== SEARCH: /api/runs IMPLEMENTATION ==="
  grep -RniE "/api/runs|api/runs|run_view|SELECT.*FROM run_view|FROM run_view" \
    server src routes app . 2>/dev/null | head -500 || true
  echo

  echo "=== POSTGRES: DOES run_view EXIST? ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "\dv+" 2>&1 || true
  echo
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "SELECT schemaname, viewname FROM pg_views WHERE viewname = 'run_view';" 2>&1 || true
  echo

  echo "=== POSTGRES: DOES tasks TABLE EXIST? ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "\dt+" 2>&1 || true
  echo
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "SELECT tablename FROM pg_tables WHERE tablename IN ('tasks','task_events');" 2>&1 || true
  echo

  echo "=== CANONICAL DASHBOARD LOGS (TAIL 120) ==="
  docker compose logs --tail 120 dashboard 2>&1 || true
  echo

  echo "=== CANONICAL POSTGRES LOGS (TAIL 120) ==="
  docker compose logs --tail 120 postgres 2>&1 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,320p' "$OUT"
