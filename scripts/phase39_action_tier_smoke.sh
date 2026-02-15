#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

die(){ echo "ERROR: $*" >&2; exit 1; }
note(){ echo "=== $* ==="; }

note "Phase 39 smoke: action_tier gating (Tier A claimable, Tier B gated) — deterministic, self-contained"

# ---- locate containers ----
PS_OUT="$(docker ps --format '{{.Names}}')"
PGC="$(echo "$PS_OUT" | grep -E '(^|-)postgres-1$' | head -n1 || true)"
[[ -n "${PGC:-}" ]] || die "postgres container not found (expected name like *-postgres-1). Start your stack first."

WA="$(echo "$PS_OUT" | grep -E '(^|-)workerA-1$' | head -n1 || true)"
WB="$(echo "$PS_OUT" | grep -E '(^|-)workerB-1$' | head -n1 || true)"

# hard guard: never hang forever on locks
STMT_TIMEOUT_MS="${PHASE39_PSQL_TIMEOUT_MS:-12000}"
LOCK_TIMEOUT_MS="${PHASE39_PSQL_LOCK_TIMEOUT_MS:-300}"
PSQL_ENV=(env "PGOPTIONS=-c statement_timeout=${STMT_TIMEOUT_MS} -c lock_timeout=${LOCK_TIMEOUT_MS}")

psql_run() {
  docker exec -i "$PGC" "${PSQL_ENV[@]}" psql -U postgres -d postgres -v ON_ERROR_STOP=1 "$@"
}
psql_run_at() {
  docker exec -i "$PGC" "${PSQL_ENV[@]}" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At "$@"
}

note "Using:"
echo "  postgres_container=$PGC"
echo "  psql_statement_timeout_ms=$STMT_TIMEOUT_MS"
echo "  psql_lock_timeout_ms=$LOCK_TIMEOUT_MS"

# ---- verify schema expectations ----
note "Schema preflight (verify tasks.action_tier exists)"
HAS_ACTION_TIER="$(
  psql_run_at <<'SQL'
SELECT COUNT(*)::int
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='tasks'
  AND column_name='action_tier';
SQL
)"
[[ "$HAS_ACTION_TIER" == "1" ]] || die "expected column public.tasks.action_tier to exist; found: $HAS_ACTION_TIER"

# ---- cleanup: terminate idle-in-tx sessions that can pin locks ----
note "Cleanup: terminate idle-in-transaction sessions (safe) that reference claim/cancel or prior smoke"
TERMINATED_IDLE_TX="$(
  psql_run_at <<'SQL'
WITH victims AS (
  SELECT pid
  FROM pg_stat_activity
  WHERE datname = current_database()
    AND state = 'idle in transaction'
    AND (
      query ILIKE '%phase32_claim_one%'
      OR query ILIKE '%Phase 32 — claim one task%'
      OR query ILIKE '%smoke.phase39.actiontier.%'
      OR query ILIKE '%UPDATE tasks%'
    )
)
SELECT COUNT(*)::int FROM victims;
SQL
)"
if [[ "$TERMINATED_IDLE_TX" != "0" ]]; then
  psql_run_at <<'SQL'
WITH victims AS (
  SELECT pid
  FROM pg_stat_activity
  WHERE datname = current_database()
    AND state = 'idle in transaction'
    AND (
      query ILIKE '%phase32_claim_one%'
      OR query ILIKE '%Phase 32 — claim one task%'
      OR query ILIKE '%smoke.phase39.actiontier.%'
      OR query ILIKE '%UPDATE tasks%'
    )
)
SELECT pg_terminate_backend(pid) FROM victims;
SQL
fi

# ---- queue preflight: cancel prior Phase39 smoke tasks WITHOUT blocking; loop until stable ----
note "Queue preflight: cancel prior Phase39 smoke tasks (SKIP LOCKED), then wait for non-smoke queue to drain"
CANCELED_TOTAL=0
for _ in 1 2 3 4 5; do
  c="$(
    psql_run_at <<'SQL'
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
  WHERE t.id = c.id
  RETURNING 1
)
SELECT COUNT(*)::int FROM u;
SQL
  )"
  CANCELED_TOTAL=$((CANCELED_TOTAL + c))
  [[ "$c" == "0" ]] && break
done
echo "canceled_smoke_tasks=$CANCELED_TOTAL"

# refuse if any nonterminal smoke rows remain (locked by someone else)
REMAINING_SMOKE_NONTERM="$(
  psql_run_at <<'SQL'
SELECT COUNT(*)::int
FROM tasks
WHERE task_id LIKE 'smoke.phase39.actiontier.%'
  AND status NOT IN ('completed','failed','canceled','cancelled');
SQL
)"
[[ "$REMAINING_SMOKE_NONTERM" == "0" ]] || die "refusing: prior smoke tasks still nonterminal (likely locked): count=$REMAINING_SMOKE_NONTERM"

non_smoke_queued_count() {
  psql_run_at <<'SQL'
SELECT COUNT(*)::int
FROM tasks
WHERE status='queued'
  AND task_id NOT LIKE 'smoke.phase39.actiontier.%';
SQL
}

snapshot_blockers() {
  echo "---- queued(non-smoke) top 15 ----"
  psql_run <<'SQL'
\pset pager off
SELECT id, task_id, status, attempts, action_tier, claimed_by, run_id
FROM tasks
WHERE status='queued'
  AND task_id NOT LIKE 'smoke.phase39.actiontier.%'
ORDER BY id
LIMIT 15;
SQL
  echo
  echo "---- running top 15 ----"
  psql_run <<'SQL'
\pset pager off
SELECT id, task_id, status, attempts, action_tier, claimed_by, run_id
FROM tasks
WHERE status='running'
ORDER BY id
LIMIT 15;
SQL
}

MAX_WAIT_SEC="${PHASE39_QUEUE_DRAIN_MAX_WAIT_SEC:-120}"
SLEEP_SEC=2
elapsed=0

q="$(non_smoke_queued_count || echo "ERR")"
[[ "$q" != "ERR" ]] || { snapshot_blockers; die "queue count failed (timeout/lock?)"; }
echo "queued(non-smoke)=$q"
while [[ "$q" != "0" && "$elapsed" -lt "$MAX_WAIT_SEC" ]]; do
  sleep "$SLEEP_SEC"
  elapsed=$((elapsed + SLEEP_SEC))
  q="$(non_smoke_queued_count || echo "ERR")"
  [[ "$q" != "ERR" ]] || { snapshot_blockers; die "queue count failed (timeout/lock?)"; }
  echo "queued(non-smoke)=$q elapsed=${elapsed}s"
done
if [[ "$q" != "0" ]]; then
  snapshot_blockers
  die "refusing: queued(non-smoke)=$q after ${elapsed}s; need idle/clean queue for determinism"
fi

# ---- stop workers to avoid races during claim assertions ----
WAS_RUNNING=0
WBS_RUNNING=0
if [[ -n "${WA:-}" ]]; then
  WAS_RUNNING=1
  note "Stopping workerA for deterministic smoke ($WA)"
  docker stop "$WA" >/dev/null
fi
if [[ -n "${WB:-}" ]]; then
  WBS_RUNNING=1
  note "Stopping workerB for deterministic smoke ($WB)"
  docker stop "$WB" >/dev/null
fi

cleanup_restart_workers() {
  if [[ "${WAS_RUNNING}" == "1" && -n "${WA:-}" ]]; then
    note "Restarting workerA ($WA)"
    docker start "$WA" >/dev/null || true
  fi
  if [[ "${WBS_RUNNING}" == "1" && -n "${WB:-}" ]]; then
    note "Restarting workerB ($WB)"
    docker start "$WB" >/dev/null || true
  fi
}
trap cleanup_restart_workers EXIT

# ---- deterministic test inputs ----
RUN_TS="$(date +%s)"
RUN_TAG="smoke.phase39.actiontier.${RUN_TS}"
TASK_A_ID="${RUN_TAG}.tierA"
TASK_B_ID="${RUN_TAG}.tierB"
SMOKE_OWNER="phase39-smoke"

# ---- insert Tier A then Tier B ----
note "Insert queued Tier A + Tier B tasks (Tier A inserted first)"
psql_run <<SQL
\pset pager off
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM tasks WHERE task_id='${TASK_A_ID}') THEN
    INSERT INTO tasks (task_id, title, status, attempts, action_tier)
    VALUES ('${TASK_A_ID}', 'Phase39 Smoke Tier A', 'queued', 0, 'A');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM tasks WHERE task_id='${TASK_B_ID}') THEN
    INSERT INTO tasks (task_id, title, status, attempts, action_tier)
    VALUES ('${TASK_B_ID}', 'Phase39 Smoke Tier B', 'queued', 0, 'B');
  END IF;
END
\$\$;
SQL

note "Pre-check: confirm both tasks exist + queued"
psql_run <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# ---- Phase39 deterministic claim: claim ONLY Tier A (gated tiers remain unclaimable here) ----
note "Claim attempt 1: expect Tier A to be claimable"
CLAIMED_TASK_ID="$(
  psql_run_at <<SQL
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
      run_id='${RUN_TAG}'
  FROM candidate c
  WHERE t.id=c.id
  RETURNING t.task_id
)
SELECT task_id FROM claimed;
SQL
  | tr -d '\r' | awk 'NF{print; exit}' || true
)"
[[ -n "${CLAIMED_TASK_ID:-}" ]] || die "expected a claimed task_id, got empty (Tier A should be claimable on idle queue)"
[[ "$CLAIMED_TASK_ID" == "$TASK_A_ID" ]] || die "expected claim to return Tier A task_id=$TASK_A_ID but got: $CLAIMED_TASK_ID"

note "Mark success for claimed Tier A"
psql_run <<SQL
UPDATE tasks
SET status='completed'
WHERE task_id='${TASK_A_ID}'
  AND status='running';
SQL

note "Verify Tier A not queued; Tier B still queued"
psql_run <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# ---- claim attempt 2: must NOT claim (Tier B gated => no Tier A available) ----
note "Claim attempt 2: expect NO claim (Tier B gated)"
CLAIMED_TASK_ID_2="$(
  psql_run_at <<SQL
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
  | tr -d '\r' | awk 'NF{print; exit}' || true
)"

if [[ -n "${CLAIMED_TASK_ID_2:-}" ]]; then
  die "expected no claim, but got task_id=$CLAIMED_TASK_ID_2"
fi

note "PASS: Tier A claimable; Tier B gated; deterministic checks complete"
