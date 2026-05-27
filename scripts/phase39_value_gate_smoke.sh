#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
COMPOSE="${COMPOSE:-docker-compose.worker.phase32.yml}"

wait_running() {
  local name="$1"
  local tries=80
  local i=0
  while (( i < tries )); do
    local st=""
    st="$(docker inspect --format "{{.State.Status}}" "$name" 2>/dev/null || true)"
    [[ "$st" == "running" ]] && return 0
    sleep 0.25
    ((i++)) || true
  done
  echo "ERROR: container not running: $name" >&2
  docker logs --tail 120 "$name" >&2 || true
  return 2
}

echo "=== ensure docker network exists ==="
docker network inspect mbhq_default >/dev/null 2>&1 || docker network create mbhq_default >/dev/null

echo "=== ensure postgres is running (expected motherboard_systems_hq-postgres-1) ==="
PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' | head -n 1 || true)"
if [[ -z "${PGC:-}" ]]; then
  if [[ -f docker-compose.yml ]]; then
    docker compose -f docker-compose.yml up -d postgres
  fi
fi
PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' | head -n 1 || true)"
: "${PGC:?ERROR: postgres container not found (expected motherboard_systems_hq-postgres-1)}"

echo "=== wait for postgres ready ==="
for i in {1..80}; do
  if docker exec -i "$PGC" pg_isready -U postgres -d postgres >/dev/null 2>&1; then
    echo "OK: postgres ready"
    break
  fi
  sleep 0.25
  if [[ "$i" == "80" ]]; then
    echo "ERROR: postgres not ready" >&2
    docker logs --tail 120 "$PGC" >&2 || true
    exit 2
  fi
done

echo "=== bring up worker stack ==="
docker compose -f "$COMPOSE" up -d --build

PS_OUT="$(docker compose -f "$COMPOSE" ps)"
WA="$(echo "$PS_OUT" | awk 'NR>1 && $1 ~ /(^|-)workerA-1$/ {print $1; exit}')"
WB="$(echo "$PS_OUT" | awk 'NR>1 && $1 ~ /(^|-)workerB-1$/ {print $1; exit}')"
: "${WA:?ERROR: workerA container not found}"
: "${WB:?ERROR: workerB container not found}"

wait_running "$WA"
wait_running "$WB"

echo "=== verify claim SQL is visible in containers ==="
docker exec -i "$WA" sh -lc 'ls -la /app/server/sql | sed -n "1,80p"'
docker exec -i "$WA" sh -lc 'test -f /app/server/sql/phase39_claim_one_with_value_gate.sql && echo "OK: workerA sees claim sql"'
docker exec -i "$WB" sh -lc 'test -f /app/server/sql/phase39_claim_one_with_value_gate.sql && echo "OK: workerB sees claim sql"'

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
A_HIT="$(docker logs --tail 300 "$WA" 2>&1 | rg -F "VALUE_GATE_REFUSE" -n || true)"
B_HIT="$(docker logs --tail 300 "$WB" 2>&1 | rg -F "VALUE_GATE_REFUSE" -n || true)"
set -e

if [ -z "$A_HIT" ] && [ -z "$B_HIT" ]; then
  echo "ERROR: expected VALUE_GATE_REFUSE log line not found in worker logs" >&2
  echo "--- workerA last 120 lines ---"
  docker logs --tail 120 "$WA" 2>&1 || true
  echo "--- workerB last 120 lines ---"
  docker logs --tail 120 "$WB" 2>&1 || true
  exit 2
fi

echo "OK: VALUE_GATE_REFUSE observed"

echo "OK: refusal logged; verify snapshots above show no worker mutation."
