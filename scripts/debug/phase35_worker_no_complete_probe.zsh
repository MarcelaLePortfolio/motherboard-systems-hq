#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

P_WORKERS="${P_WORKERS:-mbhq_phase35_workers}"
COMPOSE_FILE="${COMPOSE_FILE:-}"

banner() { echo; echo "=== $* ==="; }

pick_compose_file() {
  local f=""
  # 1) explicit env wins
  if [[ -n "${COMPOSE_FILE}" && -f "${COMPOSE_FILE}" ]]; then
    echo "${COMPOSE_FILE}"
    return 0
  fi
  local -a candidates=()
  candidates+=(${(f)"$(ls -1 docker-compose* 2>/dev/null | rg -n 'worker.*phase35|phase35.*worker' -o '^.*$' | sed 's/^[0-9]\+://g')"})
  candidates+=(${(f)"$(ls -1 docker-compose* 2>/dev/null | rg -n 'worker' -o '^.*$' | sed 's/^[0-9]\+://g')"})
  candidates+=(${(f)"$(ls -1 *.yml *.yaml 2>/dev/null | rg -n 'worker.*phase35|phase35.*worker' -o '^.*$' | sed 's/^[0-9]\+://g')"})
  candidates+=(${(f)"$(ls -1 *.yml *.yaml 2>/dev/null | rg -n 'worker' -o '^.*$' | sed 's/^[0-9]\+://g')"})
  # de-dupe while preserving order
  local -A seen
  local -a uniq=()
  for f in "${candidates[@]}"; do
    [[ -z "$f" ]] && continue
    [[ -n "${seen[$f]:-}" ]] && continue
    if [[ -f "$f" ]]; then
      seen[$f]=1
      uniq+=("$f")
    fi
  done
  if (( ${#uniq[@]} == 0 )); then
    return 1
  fi
  echo "${uniq[1]}"
}
POSTGRES_URL="${POSTGRES_URL:-postgres://postgres:postgres@127.0.0.1:5432/postgres}"
COMPOSE_FILE="$(pick_compose_file)" || {
  echo "FATAL: could not locate worker compose file."
  echo "Hint: run: ls -1 docker-compose* *.yml *.yaml | rg -n 'worker|phase35'"
  echo "Then re-run with: COMPOSE_FILE=<that file> P_WORKERS=mbhq_phase35_workers ./scripts/debug/phase35_worker_no_complete_probe.zsh"
  exit 2
}
banner "git + environment sanity"
echo "ROOT=$ROOT"
echo "P_WORKERS=$P_WORKERS"
echo "COMPOSE_FILE=$COMPOSE_FILE"
echo "POSTGRES_URL=$POSTGRES_URL"
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD
banner "compose config (resolved) — verify env wiring + SQL selections"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | sed -n '1,260p'
echo
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n 'PHASE(26|27|28|34|35)_' || true
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" config | rg -n '(CLAIM_ONE_SQL|MARK_SUCCESS_SQL|MARK_FAILURE_SQL|LEASE|EPOCH|OWNER|POSTGRES_URL)' || true

banner "worker containers list"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" ps

banner "bring workers down/up clean (worker project isolated)"
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" down -v --remove-orphans || true
docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" up -d --remove-orphans

banner "show worker env (focused) — must include POSTGRES_URL + claim/mark SQL paths"
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

banner "worker logs (last 260 lines each) — look for errors/hangs between claim and mark_success"
for svc in "${services[@]}"; do
  echo
  echo "--- logs svc=$svc ---"
  docker compose -p "$P_WORKERS" -f "$COMPOSE_FILE" logs --no-color --tail=260 "$svc" || true
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

-- Avoid COALESCE-type mismatches; order deterministically without casting assumptions.
SELECT task_id, title, status, claimed_by, claimed_at, lease_expires_at, lease_epoch
FROM tasks
WHERE status <> 'completed'
ORDER BY created_at DESC, claimed_at DESC NULLS LAST
LIMIT 25;

SELECT id, ts, task_id, kind, actor, meta
FROM task_events
ORDER BY id DESC
LIMIT 120;
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
