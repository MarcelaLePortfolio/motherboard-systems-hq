#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_claim_sql_vs_live_tasks_schema.txt"
POSTGRES_CID="$(docker compose ps -q postgres || true)"

{
  echo "PHASE 488 — TRACE CLAIM SQL VS LIVE TASKS SCHEMA"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] CURRENT WORKER FAILURE"
  echo "Observed worker error: column \"available_at\" does not exist"
  echo

  echo "[2] CLAIM SQL FILE"
  echo "===== server/worker/phase27_claim_one.sql ====="
  sed -n '1,220p' server/worker/phase27_claim_one.sql 2>/dev/null || true
  echo

  echo "[3] LIVE tasks TABLE SCHEMA"
} > "$REPORT"

if [ -n "${POSTGRES_CID}" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c "\d+ tasks" >> "$REPORT" 2>&1 || true
else
  echo "NO_POSTGRES_CONTAINER" >> "$REPORT"
fi

{
  echo
  echo "[4] LIVE tasks COLUMNS ONLY"
} >> "$REPORT"

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
  echo "[5] SEARCH FOR OTHER CLAIM SQL CANDIDATES"
  find server/worker -maxdepth 2 -type f | sort | grep -E 'claim_one|mark_success|mark_failure|phase27|phase32|phase35' || true
  echo

  echo "[6] SHOW PG CLAIM CANDIDATE IF PRESENT"
  for f in \
    server/worker/phase35_claim_one_pg.sql \
    server/worker/phase35_mark_success_pg.sql \
    server/worker/phase35_mark_failure_pg.sql
  do
    if [ -f "$f" ]; then
      echo "===== $f ====="
      sed -n '1,220p' "$f"
      echo
    fi
  done

  echo "[7] VERDICT TARGET"
  echo "- Confirm exact field mismatch between phase27_claim_one.sql and live tasks schema"
  echo "- Check whether phase35 PG SQL matches the current schema better"
  echo "- Do not mutate yet; this is proof only"
  echo

  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
