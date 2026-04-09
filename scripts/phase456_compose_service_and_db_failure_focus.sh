#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_compose_service_and_db_failure_focus.txt"

{
  echo "PHASE 456 — COMPOSE SERVICE AND DB FAILURE FOCUS"
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

  echo "=== CURRENT COMPOSE FILE ==="
  sed -n '1,260p' docker-compose.yml
  echo

  echo "=== CURRENT COMPOSE STATE ==="
  docker compose ps || true
  echo

  echo "=== ALL DASHBOARD / POSTGRES CONTAINERS ==="
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | grep -Ei 'dashboard|postgres|motherboard|mbhq|phase65|operator_guidance' || true
  echo

  echo "=== PORT OWNERS ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  echo

  echo "=== HTTP CHECKS ==="
  curl -I --max-time 10 http://localhost:8080 2>&1 || true
  curl -I --max-time 10 http://localhost:3000 2>&1 || true
  echo

  echo "=== COMPOSE LOGS: DASHBOARD ==="
  docker compose logs --tail 200 dashboard 2>&1 || true
  echo

  echo "=== COMPOSE LOGS: POSTGRES ==="
  docker compose logs --tail 200 postgres 2>&1 || true
  echo

  echo "=== SEARCH: TASK TABLE BOOTSTRAP / MIGRATION / DB URL ==="
  grep -RniE "ensureTasksTaskIdColumn|CREATE TABLE tasks|create table tasks|tasks_task_id|DB_URL|DATABASE_URL|postgres" server src scripts app . 2>/dev/null | head -500 || true
  echo

  echo "=== SEARCH: COMPOSE ENV SOURCES ==="
  grep -RniE "DB_URL|DATABASE_URL|POSTGRES|env_file|environment:" docker-compose.yml .env* . 2>/dev/null | head -300 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,320p' "$OUT"
