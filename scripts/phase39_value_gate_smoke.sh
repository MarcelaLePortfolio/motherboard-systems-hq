#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

COMPOSE="${COMPOSE:-docker-compose.worker.phase32.yml}"

echo "=== bring up worker stack (Phase 39 value gate smoke) ==="
docker compose -f "$COMPOSE" up -d --build

PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' || true)"
: "${PGC:?ERROR: postgres container not found}"

PS_OUT="$(docker compose -f "$COMPOSE" ps)"
WA="$(echo "$PS_OUT" | awk 'NR>1 && $1 ~ /(^|-)workerA-1$/ {print $1; exit}')"
WB="$(echo "$PS_OUT" | awk 'NR>1 && $1 ~ /(^|-)workerB-1$/ {print $1; exit}')"
: "${WA:?ERROR: workerA container not found}"
: "${WB:?ERROR: workerB container not found}"

TASK_ID="smoke.phase39.valuegate.$(date +%s)"
TITLE="Phase39 Value Gate Smoke"
TIER="B"

echo "=== insert Tier ${TIER} queued task (baseline mutation: INSERT only) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
INSERT INTO tasks (task_id, title, status, attempts, action_tier)
VALUES ('${TASK_ID}', '${TITLE}', 'queued', 0, '${TIER}');
SQL

echo "=== snapshot (pre-worker) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT id, task_id, status, claimed_by, attempts, action_tier
FROM tasks
WHERE task_id='${TASK_ID}';
SELECT count(*) AS task_events_for_task
FROM task_events
WHERE task_id='${TASK_ID}';
SQL

echo "=== wait for worker loop + log emission ==="
sleep 6

echo "=== snapshot (post-worker) — must be identical + no task_events added ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT id, task_id, status, claimed_by, attempts, action_tier
FROM tasks
WHERE task_id='${TASK_ID}';
SELECT count(*) AS task_events_for_task
FROM task_events
WHERE task_id='${TASK_ID}';
SQL

echo "=== assert refusal log present (either worker) ==="
set +e
docker logs --since 2m "$WA" | rg -n "VALUE_GATE_REFUSE task_id=${TASK_ID} action_tier=${TIER}" >/dev/null
A_OK=$?
docker logs --since 2m "$WB" | rg -n "VALUE_GATE_REFUSE task_id=${TASK_ID} action_tier=${TIER}" >/dev/null
B_OK=$?
set -e

if [[ "$A_OK" -ne 0 && "$B_OK" -ne 0 ]]; then
  echo "ERROR: expected VALUE_GATE_REFUSE log line not found in worker logs" >&2
  exit 2
fi

echo "OK: refusal logged; verify snapshots above show no worker mutation."
