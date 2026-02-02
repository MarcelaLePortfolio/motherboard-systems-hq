#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

P_WORKERS="${P_WORKERS:-mbhq_phase35_workers}"
COMPOSE_FILE="${COMPOSE_FILE:-}"
POSTGRES_URL="${POSTGRES_URL:-postgres://postgres:postgres@127.0.0.1:5432/postgres}"

banner() { echo; echo "=== $* ==="; }

pick_compose_file() {
  # 1) explicit env wins
  if [[ -n "${COMPOSE_FILE}" && -f "${COMPOSE_FILE}" ]]; then
    echo "${COMPOSE_FILE}"
    return 0
  fi

  # 2) prefer filenames that look like phase35 worker composes
  local f=""
  f="$(ls -1 docker-compose*.yml docker-compose*.yaml 2>/dev/null | rg -i 'phase35' | rg -i 'worker' | sort | head -n1 || true)"
  if [[ -n "$f" && -f "$f" ]]; then
    echo "$f"
    return 0
  fi

  # 3) then any docker-compose* that contains "worker" in the filename
  f="$(ls -1 docker-compose*.yml docker-compose*.yaml 2>/dev/null | rg -i 'worker' | sort | head -n1 || true)"
  if [[ -n "$f" && -f "$f" ]]; then
    echo "$f"
    return 0
  fi

  # 4) last resort: scan file contents for "worker" services
  f="$(ls -1 docker-compose*.yml docker-compose*.yaml *.yml *.yaml 2>/dev/null | sort | xargs -I{} sh -lc 'test -f "{}" && rg -q -i "services:|worker" "{}" && echo "{}"' 2>/dev/null | rg -i 'worker' | head -n1 || true)"
  if [[ -n "$f" && -f "$f" ]]; then
    echo "$f"
    return 0
  fi

  return 1
}

COMPOSE_FILE="$(pick_compose_file)" || {
  echo "FATAL: could not locate worker compose file."
  echo "Fix: run: ls -1 docker-compose* *.yml *.yaml | rg -n 'worker|phase35'"
  echo "Then: COMPOSE_FILE=<that file> P_WORKERS=mbhq_phase35_workers POSTGRES_URL=... ./scripts/debug/phase35_worker_no_complete_probe.zsh"
  exit 2
}

banner "sanity"
echo "ROOT=$ROOT"
echo "P_WORKERS=$P_WORKERS"
echo "COMPOSE_FILE=$COMPOSE_FILE"
echo "POSTGRES_URL=$POSTGRES_URL"
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD

banner "compose config (resolved) — env wiring + SQL selection"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n '^(services:|  [a-zA-Z0-9_-]+:|    image:|    command:|    entrypoint:|    environment:|      (POSTGRES_URL|PHASE(26|27|28|34|35)_|WORKER_))' || true
echo
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n '(CLAIM_ONE_SQL|MARK_SUCCESS_SQL|MARK_FAILURE_SQL|LEASE|EPOCH|OWNER|POSTGRES_URL)' || true

banner "workers: down/up (isolated project)"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" down -v --remove-orphans || true
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" up -d --remove-orphans

banner "services"
services=()
while IFS= read -r s; do services+=("$s"); done < <(docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config --services)

print -r -- "${services[@]}" | sed 's/^/ - /'

banner "worker env (focused)"
for svc in "${services[@]}"; do
  echo
  echo "--- svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" exec -T "$svc" sh -lc '
    echo "container=$(hostname)"
    env | sort | grep -E "^(POSTGRES_URL|PHASE(26|27|28|34|35)_|WORKER_|NODE_|TZ=)" || true
  ' || true
done

banner "worker logs (tail=260)"
for svc in "${services[@]}"; do
  echo
  echo "--- logs svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color --tail=260 "$svc" || true
done

banner "run Phase 35 smoke once"
set +e
SMOKE_RC=0
bash -lc 'set -euo pipefail; setopt NO_BANG_HIST; ./scripts/smoke/phase35_epoch_owner_proof.zsh' || SMOKE_RC=$?
set -e
echo "SMOKE_RC=$SMOKE_RC"

banner "DB snapshot (tasks not completed + recent task_events)"
if command -v psql >/dev/null 2>&1; then
  psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT now() AS ts;

SELECT task_id, title, status, claimed_by, claimed_at, lease_expires_at, lease_epoch, created_at
FROM tasks
WHERE status <> 'completed'
ORDER BY created_at DESC, claimed_at DESC NULLS LAST
LIMIT 25;

SELECT id, ts, task_id, kind, actor, meta
FROM task_events
ORDER BY id DESC
LIMIT 160;
SQL
else
  echo "WARN: psql not found on PATH; skipping DB snapshot."
fi

banner "if smoke failed: grep logs for claim->complete progression"
if (( SMOKE_RC != 0 )); then
  for svc in "${services[@]}"; do
    echo
    echo "--- grep svc=$svc ---"
    docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color "$svc" \
      | rg -n '(claim|claimed|reclaim|lease|epoch|owner|mark_success|mark_failure|task\.completed|completed|fatal|error|exception|Unhandled|rejected|timeout|hung|stuck)' || true
  done
fi

exit "$SMOKE_RC"
