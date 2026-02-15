#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

die(){ echo "ERROR: $*" >&2; exit 1; }
note(){ echo "=== $* ==="; }

note "Phase 39 smoke: action_tier gating (Tier A claimable, Tier B gated) — deterministic, self-contained"

# ---- locate containers ----
PGC="$(docker ps --format '{{.Names}}' | grep -E '(^|-)postgres-1$' | head -n1 || true)"
[[ -n "${PGC:-}" ]] || die "postgres container not found (expected name like *-postgres-1). Start your stack first."

# ---- locate claim SQL (prefer env override, otherwise auto-discover) ----
pick_sql_file() {
  local env_var="$1"
  local fallback_glob="$2"
  local f=""

  # 1) explicit env var points to a file
  if [[ -n "${!env_var:-}" ]]; then
    f="${!env_var}"
    [[ -f "$f" ]] || die "$env_var is set but file does not exist: $f"
    echo "$f"; return 0
  fi

  # 2) repository discovery (best-effort, deterministic order)
  # Prefer files with phase32/claim_one in name because that is the canonical claimer in current stack.
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

# ---- verify schema expectations (no schema changes; fail fast if mismatch) ----
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

# ---- create deterministic test inputs ----
RUN_TS="$(date +%s)"
RUN_TAG="smoke.phase39.actiontier.${RUN_TS}"
TASK_A_ID="${RUN_TAG}.tierA"
TASK_B_ID="${RUN_TAG}.tierB"

note "Insert queued Tier A + Tier B tasks (idempotent for this run_tag)"
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
DO \$\$
BEGIN
  -- Tier A
  IF NOT EXISTS (SELECT 1 FROM tasks WHERE task_id='${TASK_A_ID}') THEN
    INSERT INTO tasks (task_id, title, status, attempts, action_tier)
    VALUES ('${TASK_A_ID}', 'Phase39 Smoke Tier A', 'queued', 0, 'A');
  END IF;

  -- Tier B (must remain gated)
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

# ---- attempt to claim: must claim Tier A ----
note "Claim attempt 1: expect Tier A to be claimable"
CLAIMED_TASK_ID="$(
  docker exec -i "$PGC" bash -lc "psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At -f \"$CLAIM_ONE_SQL_FILE\" 2>/dev/null" \
  | tr -d '\r' \
  | head -n1 \
  || true
)"

[[ -n "${CLAIMED_TASK_ID:-}" ]] || die "expected a claimed task_id, got empty (Tier A should be claimable)"

if [[ "$CLAIMED_TASK_ID" != "$TASK_A_ID" ]]; then
  # If a different task was claimed, this smoke is not isolated. Fail deterministically.
  die "expected claim to return Tier A task_id=$TASK_A_ID but got: $CLAIMED_TASK_ID (environment not isolated; clear queue or run in clean stack)"
fi

note "Mark success for claimed Tier A"
docker exec -i "$PGC" bash -lc "psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f \"$MARK_SUCCESS_SQL_FILE\" >/dev/null"

note "Verify Tier A terminal-ish + Tier B still queued"
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT task_id, status, attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A_ID}','${TASK_B_ID}')
ORDER BY task_id;
SQL

# ---- attempt to claim again: Tier B must remain gated (no claim) ----
note "Claim attempt 2: expect NO claim (Tier B gated)"
CLAIMED_TASK_ID_2="$(
  docker exec -i "$PGC" bash -lc "psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At -f \"$CLAIM_ONE_SQL_FILE\" 2>/dev/null" \
  | tr -d '\r' \
  | head -n1 \
  || true
)"

if [[ -n "${CLAIMED_TASK_ID_2:-}" ]]; then
  if [[ "$CLAIMED_TASK_ID_2" == "$TASK_B_ID" ]]; then
    die "gating regression: Tier B was claimable (task_id=$TASK_B_ID)"
  fi
  die "expected no claim, but got task_id=$CLAIMED_TASK_ID_2 (environment not isolated; clear queue or run in clean stack)"
fi

note "PASS: Tier A claimable; Tier B gated; deterministic checks complete"
