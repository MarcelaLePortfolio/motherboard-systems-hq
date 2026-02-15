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

# ---- locate claim SQL (prefer env override, otherwise auto-discover) ----
pick_sql_file() {
  local env_var="$1"
  local fallback_glob="$2"
  local f=""

  if [[ -n "${!env_var:-}" ]]; then
    f="${!env_var}"
    [[ -f "$f" ]] || die "$env_var is set but file does not exist: $f"
    echo "$f"; return 0
  fi

  f="$(git ls-files | grep -E "$fallback_glob" | LC_ALL=C sort | head -n1 || true)"
  [[ -n "${f:-}" ]] || die "could not auto-discover SQL file for $env_var via pattern: $fallback_glob"
  echo "$f"
}

CLAIM_ONE_SQL_FILE="$(pick_sql_file "PHASE32_CLAIM_ONE_SQL" '(^|/)phase32_.*claim_one\.sql$|(^|/)claim_one\.sql$')"
MARK_SUCCESS_SQL_FILE="$(pick_sql_file "PHASE32_MARK_SUCCESS_SQL" '(^|/)phase32_.*mark_success\.sql$|(^|/)mark_success\.sql$')"

note "Using:"
echo "  postgres_container=$PGC"
echo "  claim_one_sql=$CLAIM_ONE_SQL_FILE"
echo "  mark_success_sql=$MARK_SUCCESS_SQL_FILE"

# ---- verify schema expectations ----
note "Schema preflight (verify tasks.action_tier exists)"
HAS_ACTION_TIER="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At <<'SQL'
SELECT COUNT(*)::int
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='tasks'
  AND column_name='action_tier';
SQL
)"
[[ "$HAS_ACTION_TIER" == "1" ]] || die "expected column public.tasks.action_tier to exist; found: $HAS_ACTION_TIER"

# ---- ensure queue is idle (determinism) without touching non-smoke tasks ----
note "Queue preflight: cancel prior Phase39 smoke tasks, then wait for non-smoke queue to drain"

docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
UPDATE tasks
SET status='canceled'
WHERE task_id LIKE 'smoke.phase39.actiontier.%'
  AND status IN ('queued','running');
SQL

non_smoke_queued_count() {
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At <<'SQL'
SELECT COUNT(*)::int
FROM tasks
WHERE status='queued'
  AND task_id NOT LIKE 'smoke.phase39.actiontier.%';
SQL
}

snapshot_blockers() {
  echo "---- queued(non-smoke) top 15 ----"
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
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
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT id, task_id, status, attempts, action_tier, claimed_by, run_id
FROM tasks
WHERE status='running'
ORDER BY id
LIMIT 15;
SQL
}

MAX_WAIT_SEC=120
SLEEP_SEC=2
elapsed=0

q="$(non_smoke_queued_count)"
echo "queued(non-smoke)=$q"
while [[ "$q" != "0" && "$elapsed" -lt "$MAX_WAIT_SEC" ]]; do
  sleep "$SLEEP_SEC"
  elapsed=$((elapsed + SLEEP_SEC))
  q="$(non_smoke_queued_count)"
  echo "queued(non-smoke)=$q elapsed=${elapsed}s"
done

if [[ "$q" != "0" ]]; then
  snapshot_blockers
  die "refusing: queued(non-smoke)=$q after ${elapsed}s; need idle/clean queue for determinism"
fi

# ---- stop workers to avoid races during the claim assertions ----
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

# ---- insert Tier A then Tier B ----
note "Insert queued Tier A + Tier B tasks (Tier A inserted first)"
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
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
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# ---- claim attempt 1: must claim Tier A ----
note "Claim attempt 1: expect Tier A to be claimable"
CLAIM_RAW="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At -f "$CLAIM_ONE_SQL_FILE" \
  | tr -d '\r' \
  || true
)"
CLAIMED_TASK_ID="$(
  printf "%s\n" "$CLAIM_RAW" | awk 'NF{print; exit}'
)"
[[ -n "${CLAIMED_TASK_ID:-}" ]] || die "expected a claimed task_id, got empty (Tier A should be claimable on idle queue)"
[[ "$CLAIMED_TASK_ID" == "$TASK_A_ID" ]] || die "expected claim to return Tier A task_id=$TASK_A_ID but got: $CLAIMED_TASK_ID"

note "Mark success for claimed Tier A"
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f "$MARK_SUCCESS_SQL_FILE" >/dev/null

note "Verify Tier A not queued; Tier B still queued"
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# ---- claim attempt 2: must NOT claim (Tier B gated) ----
note "Claim attempt 2: expect NO claim (Tier B gated)"
CLAIM_RAW_2="$(
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At -f "$CLAIM_ONE_SQL_FILE" \
  | tr -d '\r' \
  || true
)"
CLAIMED_TASK_ID_2="$(
  printf "%s\n" "$CLAIM_RAW_2" | awk 'NF{print; exit}'
)"

if [[ -n "${CLAIMED_TASK_ID_2:-}" ]]; then
  if [[ "$CLAIMED_TASK_ID_2" == "$TASK_B_ID" ]]; then
    die "gating regression: Tier B was claimable (task_id=$TASK_B_ID)"
  fi
  die "expected no claim, but got task_id=$CLAIMED_TASK_ID_2"
fi

note "PASS: Tier A claimable; Tier B gated; deterministic checks complete"
