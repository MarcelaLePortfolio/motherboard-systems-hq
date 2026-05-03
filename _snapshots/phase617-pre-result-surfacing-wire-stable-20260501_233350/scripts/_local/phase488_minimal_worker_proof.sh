#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase488_minimal_worker_proof.txt"
mkdir -p docs

{
  echo "PHASE 488 — MINIMAL WORKER PROOF"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] WORKER PROCESS PRESENT?"
  ps aux | grep -E 'phase26_task_worker' | grep -v grep || echo "NO_WORKER_PROCESS"
  echo

  echo "[2] WORKER BOOT PATH EXISTS?"
  grep -Rni "phase26_task_worker" server scripts 2>/dev/null | head -n 5 || echo "NO_BOOT_PATH_FOUND"
  echo

  echo "[3] WORKER TABLE EXISTS?"
  POSTGRES_CID="$(docker compose ps -q postgres || true)"
  if [ -n "${POSTGRES_CID}" ]; then
    docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
      psql -U postgres -d postgres -t -c \
      "select count(*) from pg_tables where schemaname='public' and tablename='worker_heartbeats';" \
      | tr -d ' ' || echo "DB_CHECK_FAILED"
  else
    echo "NO_POSTGRES_CONTAINER"
  fi
  echo

  echo "[4] TASK EVENT KINDS SNAPSHOT"
  if [ -n "${POSTGRES_CID}" ]; then
    docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
      psql -U postgres -d postgres -c \
      "select kind, count(*) from task_events group by kind order by kind;" || true
  fi
  echo

  echo "[5] INTERPRETATION"
  echo "- NO_WORKER_PROCESS → executor not running"
  echo "- worker table = 0 → schema not initialized"
  echo "- only task.created → lifecycle never begins"
  echo

  echo "END"
} > "$OUT"

sed -n '1,200p' "$OUT"
