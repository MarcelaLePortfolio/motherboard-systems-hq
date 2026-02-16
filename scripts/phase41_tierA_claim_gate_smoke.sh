#!/usr/bin/env bash
set -euo pipefail

setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

DC_FILE="${DC_FILE:-docker-compose.worker.phase32.yml}"

echo "=== bring up worker stack (if needed) ==="
docker compose -f "$DC_FILE" up -d

PGC="$(docker ps --format '{{.Names}}' | awk '$1=="motherboard_systems_hq-postgres-1"{print $1; exit}')"
: "${PGC:?ERROR: postgres container not found (expected motherboard_systems_hq-postgres-1)}"

echo "=== confirm action_tier column exists ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT 1
FROM information_schema.columns
WHERE table_name='tasks' AND column_name='action_tier';
SQL

echo "=== insert Tier A + Tier B tasks (queued) ==="
NOW_ID="$(date +%s)"
TASK_A="smoke.phase41.tierA.${NOW_ID}"
TASK_B="smoke.phase41.tierB.${NOW_ID}"

docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
INSERT INTO tasks (task_id, title, status, attempts, max_attempts, action_tier)
VALUES
  ('${TASK_A}', 'Phase 41 smoke: Tier A claimable', 'queued', 0, NULL, 'A'),
  ('${TASK_B}', 'Phase 41 smoke: Tier B NOT claimable', 'queued', 0, NULL, 'B');

SELECT id, task_id, status, attempts, max_attempts, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A}','${TASK_B}')
ORDER BY id;
SQL

echo "=== claim via canonical Tier-A SQL until our TASK_A is claimed ==="
CLAIMED_BY="phase41-smoke"
RUN_ID="phase41-smoke.${NOW_ID}"

max_claims=25
i=1
claimed_task_id=""

while [[ $i -le $max_claims ]]; do
  echo "--- claim attempt $i/$max_claims ---"
  out="$(
    docker exec -i "$PGC" psql -U postgres -d postgres \
      -v ON_ERROR_STOP=1 \
      -v claimed_by="${CLAIMED_BY}" \
      -v run_id="${RUN_ID}" \
      -A -t -F $'\t' \
      -f /dev/stdin < sql/phase40_claim_one_tierA.sql
  )"

  # canonical SQL emits the returned row (tab-separated) then "UPDATE 1" on a separate line.
  # Extract the first non-empty line that contains tabs (the RETURNING row).
  row="$(printf '%s\n' "$out" | awk 'NF && index($0, "\t") {print; exit}')"

  if [[ -z "${row}" ]]; then
    echo "ERROR: claim returned no row (no Tier-A queued candidates?)"
    echo "$out"
    exit 2
  fi

  # row columns (from SQL RETURNING):
  # id, task_id, title, status, action_tier, attempts, max_attempts, claimed_by, run_id
  claim_task_id="$(printf '%s' "$row" | awk -F $'\t' '{print $2}')"
  claim_tier="$(printf '%s' "$row" | awk -F $'\t' '{print $5}')"

  echo "claimed: task_id=${claim_task_id} tier=${claim_tier}"

  if [[ "${claim_tier}" != "A" ]]; then
    echo "ERROR: claimed non-Tier-A task via canonical Tier-A SQL"
    echo "$row"
    exit 3
  fi

  if [[ "${claim_task_id}" == "${TASK_B}" ]]; then
    echo "ERROR: Tier B task was claimable (gate failed)"
    echo "$row"
    exit 4
  fi

  if [[ "${claim_task_id}" == "${TASK_A}" ]]; then
    claimed_task_id="${claim_task_id}"
    break
  fi

  i=$((i+1))
done

if [[ -z "${claimed_task_id}" ]]; then
  echo "ERROR: did not reach TASK_A within ${max_claims} Tier-A claims (other Tier-A work may be ahead in queue)"
  echo "TASK_A=${TASK_A}"
  exit 5
fi

echo "=== verify DB state: TASK_A running, TASK_B still queued ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT task_id, status, action_tier, claimed_by, run_id
FROM tasks
WHERE task_id IN ('${TASK_A}','${TASK_B}')
ORDER BY task_id;
SQL

echo "OK: Phase 41 smoke passed (canonical claim only yields Tier A; Tier B remains queued; TASK_A claimed)."
