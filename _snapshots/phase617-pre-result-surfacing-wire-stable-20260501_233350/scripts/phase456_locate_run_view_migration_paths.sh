#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_locate_run_view_migration_paths.txt"

{
  echo "PHASE 456 — LOCATE RUN_VIEW MIGRATION PATHS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo

  echo "=== REPO SEARCH: run_view migration files ==="
  find . -type f | grep -Ei '0007.*run_view|run_view_contract|phase36.*run_view' | sort || true
  echo

  echo "=== REPO SEARCH: drizzle/sql migration directories ==="
  find . -type d | grep -Ei 'drizzle|migrations|sql' | sort || true
  echo

  echo "=== CONTENT SEARCH: run_view DDL references ==="
  grep -RniE 'CREATE( OR REPLACE)? VIEW run_view|run_view_contract|0007_phase36_1_run_view|0007_phase36_2_run_view_contract' . 2>/dev/null | head -300 || true
  echo

  echo "=== CONTAINER SEARCH: dashboard filesystem candidates ==="
  docker compose exec -T dashboard sh -lc 'find /app -type f | grep -Ei "0007.*run_view|run_view_contract|phase36.*run_view" | sort' || true
  echo

  echo "=== CONTAINER SEARCH: dashboard migration/sql directories ==="
  docker compose exec -T dashboard sh -lc 'find /app -type d | grep -Ei "drizzle|migrations|sql" | sort' || true
  echo
} | tee "$OUT"
