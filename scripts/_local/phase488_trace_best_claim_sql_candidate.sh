#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_best_claim_sql_candidate_trace.txt"
POSTGRES_CID="$(docker compose ps -q postgres || true)"

{
  echo "PHASE 488 — TRACE BEST CLAIM SQL CANDIDATE"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] CURRENT LIVE tasks SCHEMA"
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
  echo "[2] CLAIM SQL CANDIDATES"
  for f in \
    server/worker/phase27_claim_one.sql \
    server/worker/phase28_claim_one.sql \
    server/worker/phase32_claim_one.sql \
    server/worker/phase34_claim_one.sql \
    server/worker/phase34_claim_one_pg.sql \
    server/worker/phase35_claim_one_pg.sql
  do
    if [ -f "$f" ]; then
      echo "===== $f ====="
      sed -n '1,220p' "$f"
      echo
    fi
  done

  echo "[3] SUCCESS / FAILURE SQL CANDIDATES"
  for f in \
    server/worker/phase27_mark_success.sql \
    server/worker/phase27_mark_failure.sql \
    server/worker/phase28_mark_success.sql \
    server/worker/phase28_mark_failure.sql \
    server/worker/phase32_mark_success.sql \
    server/worker/phase32_mark_failure.sql \
    server/worker/phase34_mark_success.sql \
    server/worker/phase34_mark_failure.sql \
    server/worker/phase34_mark_success_pg.sql \
    server/worker/phase34_mark_failure_pg.sql \
    server/worker/phase35_mark_success.sql \
    server/worker/phase35_mark_failure.sql \
    server/worker/phase35_mark_success_pg.sql \
    server/worker/phase35_mark_failure_pg.sql
  do
    if [ -f "$f" ]; then
      echo "===== $f ====="
      sed -n '1,220p' "$f"
      echo
    fi
  done

  echo "[4] TASK STATUS DISTRIBUTION"
} >> "$REPORT"

if [ -n "${POSTGRES_CID}" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c \
    "select status, count(*) from tasks group by status order by status;" \
    >> "$REPORT" 2>&1 || true
else
  echo "NO_POSTGRES_CONTAINER" >> "$REPORT"
fi

{
  echo
  echo "[5] SEARCH: WHICH SQL PATHS THE WORKER CAN ACCEPT"
  grep -nE 'PHASE32_CLAIM_ONE_SQL|PHASE27_CLAIM_ONE_SQL|PHASE32_MARK_SUCCESS_SQL|PHASE27_MARK_SUCCESS_SQL|PHASE32_MARK_FAILURE_SQL|PHASE27_MARK_FAILURE_SQL|PHASE34_ENABLE_LEASE' \
    server/worker/phase26_task_worker.mjs || true
  echo

  echo "[6] VERDICT TARGET"
  echo "- Identify which claim SQL family matches the live tasks schema best"
  echo "- Identify whether status mismatch is also present (queued vs created)"
  echo "- Do not mutate yet; choose the smallest compatible SQL path first"
  echo

  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,360p' "$REPORT"
