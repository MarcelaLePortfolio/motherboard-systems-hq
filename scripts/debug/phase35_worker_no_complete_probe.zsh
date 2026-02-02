#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

P_WORKERS="${P_WORKERS:-mbhq_phase35_workers}"
COMPOSE_FILE="${COMPOSE_FILE:-}"

# Find the Phase 35 worker compose file (prefer explicit, otherwise best-guess).
if [[ -z "${COMPOSE_FILE}" ]]; then
  for f in docker-compose.worker.phase35.yml docker-compose.worker.phase35.yaml docker-compose.worker.phase35_epoch_owner.yml docker-compose.worker.phase35_epoch_owner.yaml docker-compose.worker.yml; do
    if [[ -f "$f" ]]; then COMPOSE_FILE="$f"; break; fi
  done
fi
if [[ -z "${COMPOSE_FILE}" || ! -f "${COMPOSE_FILE}" ]]; then
  echo "FATAL: could not locate worker compose file. Set COMPOSE_FILE=... and re-run."
  exit 2
fi

POSTGRES_URL="${POSTGRES_URL:-postgres://postgres:postgres@127.0.0.1:5432/postgres}"

banner() { echo; echo "=== $* ==="; }

banner "git + environment sanity"
echo "ROOT=$ROOT"
echo "P_WORKERS=$P_WORKERS"
echo "COMPOSE_FILE=$COMPOSE_FILE"
echo "POSTGRES_URL=$POSTGRES_URL"
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD

banner "compose config (resolved) — verify env wiring + SQL selections"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | sed -n '1,240p'
echo
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n 'PHASE(26|27|28|34|35)_' || true
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n '(CLAIM_ONE_SQL|MARK_SUCCESS_SQL|MARK_FAILURE_SQL|LEASE|EPOCH|OWNER|POSTGRES_URL)' || true

banner "worker containers list"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" ps

banner "bring workers down/up clean (worker project isolated)"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" down -v --remove-orphans || true
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" up -d --remove-orphans

banner "show worker env (focused) — must include POSTGRES_URL + claim/mark SQL paths"
# Try common service names; fall back to enumerating compose services.
services=()
while IFS= read -r s; do services+=("$s"); done < <(docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config --services)
for svc in "${services[@]}"; do
  echo
  echo "--- svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" exec -T "$svc" sh -lc '
    echo "container=$(hostname)"
    env | sort | grep -E "^(POSTGRES_URL|PHASE(26|27|28|34|35)_|WORKER_|NODE_|TZ=)" || true
  ' || true
done

banner "worker logs (last 220 lines each) — look for errors/hangs between claim and mark_success"
for svc in "${services[@]}"; do
  echo
  echo "--- logs svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color --tail=220 "$svc" || true
done

banner "run Phase 35 smoke once (capture failure context, then DB snapshot)"
set +e
SMOKE_RC=0
bash -lc 'set -euo pipefail; setopt NO_BANG_HIST; ./scripts/smoke/phase35_epoch_owner_proof.zsh' || SMOKE_RC=$?
set -e
echo "SMOKE_RC=$SMOKE_RC"

banner "DB snapshot: tasks + task_events (latest)"
if command -v psql >/dev/null 2>&1; then
  psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT now() AS ts;
SELECT task_id, status, claimed_by, claimed_at, lease_expires_at, lease_epoch
FROM tasks
ORDER BY COALESCE(claimed_at, created_at) DESC
LIMIT 15;

SELECT id, ts, task_id, kind, actor, meta
FROM task_events
ORDER BY id DESC
LIMIT 40;
SQL
else
  echo "WARN: psql not found on PATH; skipping direct DB snapshot."
fi

banner "if smoke failed: grep logs for claim/complete markers"
if (( SMOKE_RC != 0 )); then
  for svc in "${services[@]}"; do
    echo
    echo "--- grep svc=$svc ---"
    docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color "$svc" \
      | rg -n '(claim|claimed|reclaim|lease|epoch|owner|mark_success|mark_failure|completed|task\.completed|fatal|error|exception|Unhandled|rejected|timeout|hung|stuck)' || true
  done
fi

exit "$SMOKE_RC"
