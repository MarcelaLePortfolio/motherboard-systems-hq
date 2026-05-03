#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_phase32_minimum_schema_gap.txt"
POSTGRES_CID="$(docker compose ps -q postgres || true)"

{
  echo "PHASE 488 — TRACE PHASE32 MINIMUM SCHEMA GAP"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] WORKER CALL SHAPE (PHASE32-COMPATIBLE TARGET)"
  echo "claimOne(c, run_id)        -> 2 params"
  echo "markSuccess(task_id, run_id, actor) -> 3 params"
  echo "markFailure(task_id, run_id, actor) -> 3 params"
  echo

  echo "[2] PHASE32 SQL CONTRACTS"
  for f in \
    server/worker/phase32_claim_one.sql \
    server/worker/phase32_mark_success.sql \
    server/worker/phase32_mark_failure.sql
  do
    echo "===== $f ====="
    sed -n '1,220p' "$f" 2>/dev/null || true
    echo
  done

  echo "[3] LIVE tasks COLUMNS"
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
  echo "[4] REQUIRED PHASE32 TASK COLUMNS CHECK"
} >> "$REPORT"

if [ -n "${POSTGRES_CID}" ]; then
  docker exec -e PGPASSWORD=postgres "$POSTGRES_CID" \
    psql -U postgres -d postgres -c "
      select req.column_name,
             case when c.column_name is null then 'MISSING' else 'PRESENT' end as status,
             c.data_type
      from (
        values
          ('task_id'),
          ('status'),
          ('attempts'),
          ('max_attempts'),
          ('next_run_at'),
          ('run_id'),
          ('claimed_by'),
          ('completed_at')
      ) as req(column_name)
      left join information_schema.columns c
        on c.table_schema='public'
       and c.table_name='tasks'
       and c.column_name=req.column_name
      order by req.column_name;
    " >> "$REPORT" 2>&1 || true
else
  echo "NO_POSTGRES_CONTAINER" >> "$REPORT"
fi

{
  echo
  echo "[5] TASK STATUS DISTRIBUTION"
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
  echo "[6] MIGRATION / BOOTSTRAP CANDIDATES FOR MISSING PHASE32 FIELDS"
  grep -RniE 'attempts|next_run_at|claimed_by|completed_at|phase29_db_migrate_to_phase27|db_bootstrap' \
    server scripts 2>/dev/null || true
  echo

  echo "[7] VERDICT"
  echo "- Phase27 family is arity-incompatible with current worker calls"
  echo "- Phase32 family is the first SQL family whose parameter counts align with worker call shape"
  echo "- This trace isolates the remaining schema gap before any bounded mutation"
  echo

  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
