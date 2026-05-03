#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_worker_call_arity_vs_sql_contract.txt"

{
  echo "PHASE 488 — TRACE WORKER CALL ARITY VS SQL CONTRACT"
  echo "Timestamp: $(date)"
  echo "==============================================="
  echo

  echo "[1] WORKER CALL SITES / PARAM SHAPES"
  nl -ba server/worker/phase26_task_worker.mjs | sed -n '1,260p' || true
  echo

  echo "[2] PHASE27 SQL CONTRACTS"
  for f in \
    server/worker/phase27_claim_one.sql \
    server/worker/phase27_mark_success.sql \
    server/worker/phase27_mark_failure.sql
  do
    echo "===== $f ====="
    sed -n '1,220p' "$f" 2>/dev/null || true
    echo
  done

  echo "[3] PHASE28 CLAIM SQL (2-param candidate)"
  echo "===== server/worker/phase28_claim_one.sql ====="
  sed -n '1,220p' server/worker/phase28_claim_one.sql 2>/dev/null || true
  echo

  echo "[4] PHASE32 SQL CONTRACTS"
  for f in \
    server/worker/phase32_claim_one.sql \
    server/worker/phase32_mark_success.sql \
    server/worker/phase32_mark_failure.sql
  do
    echo "===== $f ====="
    sed -n '1,220p' "$f" 2>/dev/null || true
    echo
  done

  echo "[5] LIVE tasks STATUS COUNTS"
} > "$REPORT"

POSTGRES_CID="$(docker compose ps -q postgres || true)"
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
  echo "[6] VERDICT TARGET"
  echo "- Confirm exact arity expected by claimOne / markSuccess / markFailure calls"
  echo "- Confirm whether phase27 family is fundamentally incompatible with worker call shape"
  echo "- Decide smallest next move: swap only claim SQL to phase28 vs move whole family to phase32-compatible path"
  echo

  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,360p' "$REPORT"
