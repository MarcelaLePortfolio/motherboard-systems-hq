#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Phase 35 worker project isolation
P_WORKERS="${P_WORKERS:-mbhq_phase35_workers}"

# You do NOT have a phase35 compose file at repo root; use the known worker compose (phase34) unless overridden.
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.worker.phase34.yml}"
POSTGRES_URL="${POSTGRES_URL:-postgres://postgres:postgres@127.0.0.1:5432/postgres}"

banner(){ echo; echo "=== $* ==="; }

banner "sanity"
echo "ROOT=$ROOT"
echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
echo "SHA=$(git rev-parse --short HEAD)"
echo "P_WORKERS=$P_WORKERS"
echo "COMPOSE_FILE=$COMPOSE_FILE"
echo "POSTGRES_URL=$POSTGRES_URL"
test -f "$COMPOSE_FILE"

banner "compose: services + critical env wiring (resolved)"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config --services
echo
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n '(POSTGRES_URL|WORKER_OWNER|PHASE(26|27|32|34|35)_(CLAIM_ONE_SQL|MARK_SUCCESS_SQL|MARK_FAILURE_SQL|HEARTBEAT|RECLAIM)|LEASE|EPOCH|OWNER)' || true

banner "restart workers (isolated project)"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" down -v --remove-orphans || true
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" up -d --remove-orphans

banner "tail worker logs (first 260 lines each)"
for svc in $(docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config --services); do
  echo
  echo "--- svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color --tail=260 "$svc" || true
done

banner "run Phase 35 smoke once (capture rc)"
set +e
./scripts/smoke/phase35_epoch_owner_proof.zsh
SMOKE_RC=$?
set -e
echo "SMOKE_RC=$SMOKE_RC"

banner "DB: introspect schema + show freshest rows (NO column assumptions)"
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT now() AS ts_utc;

-- Real columns (authoritative)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema='public' AND table_name='tasks'
ORDER BY ordinal_position;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema='public' AND table_name='task_events'
ORDER BY ordinal_position;

-- Fresh tasks
SELECT *
FROM tasks
ORDER BY created_at DESC
LIMIT 12;

-- Fresh task_events (avoid assuming a timestamp column)
SELECT *
FROM task_events
ORDER BY id DESC
LIMIT 120;
SQL

banner "greps: worker progression and errors"
for svc in $(docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config --services); do
  echo
  echo "--- grep svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color "$svc" \
    | rg -n '(claim|claimed|reclaim|lease|epoch|owner|mark_success|mark_failure|task\.completed|completed|fatal|error|exception|Unhandled|rejected|timeout|hung|stuck)' || true
done

exit "$SMOKE_RC"
