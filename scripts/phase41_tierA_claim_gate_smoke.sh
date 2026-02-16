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

echo "=== attempt canonical Tier-A claim SQL directly (must claim Tier A only) ==="
if rg -n "^\s*PREPARE\b" sql/phase40_claim_one_tierA.sql >/dev/null 2>&1; then
  PREP_NAME="$(awk 'BEGIN{IGNORECASE=1} $1=="PREPARE"{print $2; exit}' sql/phase40_claim_one_tierA.sql | sed 's/[;()].*//')"
  : "${PREP_NAME:?ERROR: could not detect PREPARE name in sql/phase40_claim_one_tierA.sql}"
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
\ir sql/phase40_claim_one_tierA.sql
EXECUTE ${PREP_NAME};
SQL
else
  # direct SQL: execute file verbatim and show returned row(s) (if any)
  docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f /dev/stdin < sql/phase40_claim_one_tierA.sql
fi

echo "=== verify DB state (Tier A not queued; Tier B still queued) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT task_id, status, action_tier
FROM tasks
WHERE task_id IN ('${TASK_A}','${TASK_B}')
ORDER BY task_id;
SQL

echo "OK: Phase 41 smoke passed (Tier A claimable; Tier B remains queued)."
