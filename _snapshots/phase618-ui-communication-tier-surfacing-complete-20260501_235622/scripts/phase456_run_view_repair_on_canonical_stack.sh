#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_run_view_repair_on_canonical_stack.txt"

{
  echo "PHASE 456 — RUN_VIEW REPAIR ON CANONICAL STACK"
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

  echo "=== VERIFY EXPECTED MIGRATION FILES IN REPO ==="
  ls -l migrations/drizzle_pg/0007_phase36_1_run_view.sql
  ls -l migrations/drizzle_pg/0007_phase36_2_run_view_contract.sql
  echo

  echo "=== VERIFY EXPECTED MIGRATION FILES IN DASHBOARD CONTAINER ==="
  docker compose exec -T dashboard sh -lc 'ls -l /app/migrations/drizzle_pg/0007_phase36_1_run_view.sql /app/migrations/drizzle_pg/0007_phase36_2_run_view_contract.sql'
  echo

  echo "=== CHECK WHETHER run_view EXISTS BEFORE REPAIR ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -Atqc "SELECT schemaname || '.' || viewname FROM pg_views WHERE viewname = 'run_view';" || true
  echo

  RUN_VIEW_EXISTS="$(docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -Atqc "SELECT COUNT(*) FROM pg_views WHERE viewname = 'run_view';" | tr -d '\r' || echo 0)"
  echo "run_view_exists_before=${RUN_VIEW_EXISTS}"
  echo

  if [ "${RUN_VIEW_EXISTS}" = "0" ]; then
    echo "=== APPLY ONLY RUN_VIEW MIGRATIONS TO CANONICAL POSTGRES ==="
    docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -v ON_ERROR_STOP=1 < migrations/drizzle_pg/0007_phase36_1_run_view.sql
    docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -v ON_ERROR_STOP=1 < migrations/drizzle_pg/0007_phase36_2_run_view_contract.sql
  else
    echo "run_view already exists; no migration applied."
  fi
  echo

  echo "=== CHECK WHETHER run_view EXISTS AFTER REPAIR ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -Atqc "SELECT schemaname || '.' || viewname FROM pg_views WHERE viewname = 'run_view';"
  echo

  echo "=== SAMPLE run_view QUERY ==="
  docker compose exec -T postgres psql -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}" -c "SELECT * FROM run_view LIMIT 5;" || true
  echo

  echo "=== API VERIFICATION AFTER REPAIR ==="
  curl -sS --max-time 10 http://localhost:8080/api/runs?limit=5
  echo
  echo
  curl -sS --max-time 10 http://localhost:8080/api/tasks?limit=5
  echo
  echo

  echo "=== CANONICAL DASHBOARD LOGS AFTER REPAIR (TAIL 120) ==="
  docker compose logs --tail 120 dashboard 2>&1 || true
  echo

  echo "=== CANONICAL POSTGRES LOGS AFTER REPAIR (TAIL 120) ==="
  docker compose logs --tail 120 postgres 2>&1 || true
  echo
} | tee "$OUT"
