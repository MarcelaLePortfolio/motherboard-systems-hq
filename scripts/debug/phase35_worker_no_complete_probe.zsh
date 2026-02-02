#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

P_WORKERS="${P_WORKERS:-mbhq_phase35_workers}"
COMPOSE_FILE="${COMPOSE_FILE:-}"
POSTGRES_URL="${POSTGRES_URL:-postgres://postgres:postgres@127.0.0.1:5432/postgres}"

banner() { echo; echo "=== $* ==="; }

# Robust, zsh-safe file discovery (no bare globs; no "no matches found").
list_compose_candidates() {
  find . -maxdepth 1 -type f \( \
      -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' -o \
      -name '*.yml' -o -name '*.yaml' \
    \) -print 2>/dev/null \
  | sed 's|^\./||' \
  | sort
}

pick_compose_file() {
  # 1) explicit env wins
  if [[ -n "${COMPOSE_FILE}" && -f "${COMPOSE_FILE}" ]]; then
    echo "${COMPOSE_FILE}"
    return 0
  fi

  local -a files
  files=("${(@f)$(list_compose_candidates)}")
  # 2) prefer phase35+worker in filename
  local f
  for f in "${files[@]}"; do
    [[ -z "$f" ]] && continue
    if echo "$f" | rg -qi 'phase35' && echo "$f" | rg -qi 'worker'; then
      echo "$f"
      return 0
    fi
  done

  # 3) then any filename with worker
  for f in "${files[@]}"; do
    [[ -z "$f" ]] && continue
    if echo "$f" | rg -qi 'worker'; then
      echo "$f"
      return 0
    fi
  done

  # 4) last resort: scan contents for "worker" mentions
  for f in "${files[@]}"; do
    [[ -z "$f" ]] && continue
    if rg -qi 'worker' "$f" 2>/dev/null; then
      echo "$f"
      return 0
    fi
  done

  return 1
}

COMPOSE_FILE="$(pick_compose_file)" || {
  echo "FATAL: could not locate worker compose file."
  echo
  echo "Candidates:"
  list_compose_candidates | sed 's/^/ - /'
  echo
  echo "Fix: set COMPOSE_FILE explicitly, e.g.:"
  echo "  COMPOSE_FILE=<one of the above> P_WORKERS=$P_WORKERS POSTGRES_URL=... ./scripts/debug/phase35_worker_no_complete_probe.zsh"
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

banner "DB schema + snapshot (avoid assuming column names)"
if command -v psql >/dev/null 2>&1; then
  psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT now() AS ts;

-- Show real columns (your earlier error suggests task_events has no "ts" column).
\d+ tasks
\d+ task_events

-- Tasks that are not completed (order deterministically without COALESCE type traps).
SELECT task_id, title, status, claimed_by, claimed_at, lease_expires_at, lease_epoch, created_at
FROM tasks
WHERE status <> 'completed'
ORDER BY created_at DESC, claimed_at DESC NULLS LAST
LIMIT 25;

-- Recent task_events with only "likely" columns; if this errors, the \d+ above tells us the truth.
SELECT id, task_id, kind, actor, meta
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
