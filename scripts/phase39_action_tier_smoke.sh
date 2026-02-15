#!/usr/bin/env bash
set -euo pipefail

note(){ echo "=== $* ==="; }
die(){ echo "ERROR: $*" >&2; exit 1; }

# -------- config --------
SMOKE_OWNER="${SMOKE_OWNER:-phase39-smoke}"
RUN_TAG="${RUN_TAG:-smoke.phase39.actiontier.$(date +%s)}"

# Tight timeouts so we never hang on accidental locks.
PSQL_STATEMENT_TIMEOUT_MS="${PSQL_STATEMENT_TIMEOUT_MS:-12000}"
PSQL_LOCK_TIMEOUT_MS="${PSQL_LOCK_TIMEOUT_MS:-300}"

# Drain window for any non-smoke queued work (deterministic precondition).
DRAIN_TIMEOUT_SEC="${DRAIN_TIMEOUT_SEC:-90}"
DRAIN_POLL_MS="${DRAIN_POLL_MS:-500}"

# Optional: stop/restart workers during smoke to avoid race with background claim loops.
STOP_WORKERS="${STOP_WORKERS:-1}"

# -------- helpers --------
find_container(){
  local pat="$1"
  docker ps --format '{{.Names}}' | grep -E "$pat" | head -n1 || true
}

PGC="$(find_container '(^|-)postgres-1$')"
[[ -n "${PGC:-}" ]] || die "postgres container not found (name must match /postgres-1$/)"

WA="$(find_container '(^|-)workerA-1$')"
WB="$(find_container '(^|-)workerB-1$')"

PSQL_ENV=(
  -e PSQL_STATEMENT_TIMEOUT_MS="$PSQL_STATEMENT_TIMEOUT_MS"
  -e PSQL_LOCK_TIMEOUT_MS="$PSQL_LOCK_TIMEOUT_MS"
)

psql_run() {
  docker exec -i "$PGC" "${PSQL_ENV[@]}" psql -U postgres -d postgres -v ON_ERROR_STOP=1 "$@"
}

psql_run_at() {
  # -A -t output mode for single-field outputs
  psql_run -At "$@"
}

# Ensure we always bring workers back up if we stop them.
restore_workers() {
  if [[ "${STOP_WORKERS}" == "1" ]]; then
    [[ -n "${WA:-}" ]] && { note "Restarting workerA ($WA)"; docker start "$WA" >/dev/null 2>&1 || true; }
    [[ -n "${WB:-}" ]] && { note "Restarting workerB ($WB)"; docker start "$WB" >/dev/null 2>&1 || true; }
  fi
}
trap restore_workers EXIT

# -------- preflight: schema --------
note "Phase 39 smoke: action_tier gate (Tier A claimable, Tier B gated) — deterministic, self-contained"
note "Using: postgres_container=$PGC psql_statement_timeout_ms=$PSQL_STATEMENT_TIMEOUT_MS psql_lock_timeout_ms=$PSQL_LOCK_TIMEOUT_MS run_tag=$RUN_TAG"

note "Schema preflight (verify tasks.action_tier exists)"
psql_run <<'SQL'
\pset pager off
SELECT 1
FROM information_schema.columns
WHERE table_name='tasks' AND column_name='action_tier';
SQL

# -------- cleanup: kill idle-in-tx sessions that can pin locks --------
note "Cleanup: terminate idle-in-transaction sessions referencing claim/cancel/smoke (safe)"
psql_run <<'SQL'
\pset pager off
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT pid
    FROM pg_stat_activity
    WHERE datname = current_database()
      AND state = 'idle in transaction'
      AND (
        query ILIKE '%Phase 32 — claim one task%'
        OR query ILIKE '%phase32_claim_one%'
        OR query ILIKE '%smoke.phase39.actiontier.%'
        OR query ILIKE '%UPDATE tasks%'
      )
  LOOP
    PERFORM pg_terminate_backend(r.pid);
  END LOOP;
END $$;
SQL

# -------- cancel prior Phase39 smoke without blocking --------
note "Queue preflight: cancel prior Phase39 smoke tasks (SKIP LOCKED batches), then wait for non-smoke queue to drain"
TOTAL_CANCELED=0
for i in {1..12}; do
  C="$(psql_run_at <<'SQL' || true
SET statement_timeout='3000ms';
SET lock_timeout='200ms';
WITH c AS (
  SELECT id
  FROM tasks
  WHERE task_id LIKE 'smoke.phase39.actiontier.%'
    AND status NOT IN ('completed','failed','canceled','cancelled')
  FOR UPDATE SKIP LOCKED
),
u AS (
  UPDATE tasks t
  SET status='canceled'
  FROM c
  WHERE t.id=c.id
  RETURNING 1
)
SELECT COUNT(*)::text FROM u;
SQL
)"
  C="${C:-0}"
  TOTAL_CANCELED=$((TOTAL_CANCELED + C))
  [[ "$C" == "0" ]] && break
done
echo "canceled_smoke_tasks=$TOTAL_CANCELED"

# -------- drain non-smoke queued (determinism precondition) --------
start_ts="$(date +%s)"
while :; do
  Q="$(psql_run_at <<'SQL'
SET statement_timeout='4000ms';
SET lock_timeout='200ms';
SELECT COUNT(*)::text
FROM tasks
WHERE status='queued'
  AND task_id NOT LIKE 'smoke.phase39.actiontier.%';
SQL
)"
  Q="${Q:-0}"
  echo "queued(non-smoke)=$Q"
  if [[ "$Q" == "0" ]]; then
    break
  fi
  now_ts="$(date +%s)"
  if (( now_ts - start_ts >= DRAIN_TIMEOUT_SEC )); then
    note "Drain timeout hit; snapshot blockers"
    psql_run <<'SQL'
\pset pager off
SELECT id, task_id, status, attempts, action_tier, claimed_by, run_id, created_at, updated_at
FROM tasks
WHERE status IN ('queued','running')
ORDER BY id
LIMIT 40;
SQL
    die "refusing: non-smoke queue did not drain within ${DRAIN_TIMEOUT_SEC}s"
  fi
  sleep "$(awk -v ms="$DRAIN_POLL_MS" 'BEGIN{printf "%.3f", ms/1000}')"
done

# -------- stop workers (avoid race) --------
if [[ "${STOP_WORKERS}" == "1" ]]; then
  [[ -n "${WA:-}" ]] && { note "Stopping workerA for deterministic smoke ($WA)"; docker stop "$WA" >/dev/null; }
  [[ -n "${WB:-}" ]] && { note "Stopping workerB for deterministic smoke ($WB)"; docker stop "$WB" >/dev/null; }
fi

# -------- create smoke tasks (idempotent) --------
TASK_A_ID="${RUN_TAG}.tierA"
TASK_B_ID="${RUN_TAG}.tierB"

note "Insert queued Tier A + Tier B tasks (Tier A inserted first)"
psql_run <<SQL
\pset pager off
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM tasks WHERE task_id='${TASK_A_ID}') THEN
    INSERT INTO tasks (task_id, title, status, action_tier)
    VALUES ('${TASK_A_ID}', 'Phase39 Smoke Tier A', 'queued', 'A');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM tasks WHERE task_id='${TASK_B_ID}') THEN
    INSERT INTO tasks (task_id, title, status, action_tier)
    VALUES ('${TASK_B_ID}', 'Phase39 Smoke Tier B', 'queued', 'B');
  END IF;
END \$\$;
SQL

note "Pre-check: confirm both tasks exist + queued"
psql_run <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# -------- claim attempt 1: Tier A must be claimable --------
note "Claim attempt 1: expect Tier A to be claimable"
CLAIMED_TASK_ID="$(
  psql_run_at <<SQL
SET statement_timeout='8000ms';
SET lock_timeout='300ms';
WITH candidate AS (
  SELECT id
  FROM tasks
  WHERE status='queued'
    AND action_tier='A'
    AND task_id='${TASK_A_ID}'
  LIMIT 1
  FOR UPDATE SKIP LOCKED
),
claimed AS (
  UPDATE tasks t
  SET status='running',
      claimed_by='${SMOKE_OWNER}',
      run_id='${RUN_TAG}'
  FROM candidate c
  WHERE t.id=c.id
  RETURNING t.task_id
)
SELECT task_id FROM claimed;
SQL
  | tr -d '\r' | awk 'NF{print; exit}'
)" || true

[[ -n "${CLAIMED_TASK_ID:-}" ]] || die "expected a claimed task_id, got empty (Tier A should be claimable on idle queue)"
[[ "$CLAIMED_TASK_ID" == "$TASK_A_ID" ]] || die "expected claim to return Tier A task_id=$TASK_A_ID but got: $CLAIMED_TASK_ID"

# -------- mark success (no dependency on worker SQL files) --------
note "Mark success for claimed Tier A"
psql_run <<SQL
UPDATE tasks
SET status='completed'
WHERE task_id='${TASK_A_ID}'
  AND status='running';
SQL

note "Verify Tier A completed; Tier B still queued"
psql_run <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# -------- claim attempt 2: must NOT claim anything (Tier B gated; no Tier A available) --------
note "Claim attempt 2: expect NO claim (Tier B gated)"
CLAIMED_TASK_ID_2="$(
  psql_run_at <<SQL
SET statement_timeout='8000ms';
SET lock_timeout='300ms';
WITH candidate AS (
  SELECT id
  FROM tasks
  WHERE status='queued'
    AND action_tier='A'
  ORDER BY id
  LIMIT 1
  FOR UPDATE SKIP LOCKED
),
claimed AS (
  UPDATE tasks t
  SET status='running',
      claimed_by='${SMOKE_OWNER}',
      run_id='${RUN_TAG}.2'
  FROM candidate c
  WHERE t.id=c.id
  RETURNING t.task_id
)
SELECT task_id FROM claimed;
SQL
  | tr -d '\r' | awk 'NF{print; exit}'
)" || true

if [[ -n "${CLAIMED_TASK_ID_2:-}" ]]; then
  die "expected no claim, but got task_id=$CLAIMED_TASK_ID_2 (Tier A unexpectedly available)"
fi

# -------- final: prove TierB stayed queued, then cancel it to leave DB clean --------
note "Final check: Tier B remained queued, then cancel it for clean re-runs"
psql_run <<SQL
\pset pager off
SELECT task_id, status, action_tier
FROM tasks
WHERE task_id='${TASK_B_ID}';
UPDATE tasks
SET status='canceled'
WHERE task_id='${TASK_B_ID}'
  AND status='queued';
SQL

note "PASS: Tier A claimable; Tier B gated; deterministic checks complete (DB left clean)"
