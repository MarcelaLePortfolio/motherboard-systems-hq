#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

# portable "timeout": prefer gtimeout (coreutils on mac), then timeout, else python
_timeout() {
  local seconds="$1"; shift
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$seconds" "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$seconds" "$@"
  else
    python3 - <<PY
import subprocess, sys
try:
  subprocess.run(sys.argv[2:], timeout=float(sys.argv[1]), check=False)
except subprocess.TimeoutExpired:
  pass
PY
  "$seconds" "$@"
  fi
}

echo "== Phase 33 smoke =="

# best-effort compose up; do not fail smoke if postgres can't bind 5432 (common local conflict)
if [[ -f docker-compose.yml ]]; then
  echo "== docker compose up (best-effort) =="
  set +e
  docker compose up -d --remove-orphans
  echo "docker_compose_rc=$?"
  set -e
fi

echo "== SSE hello/heartbeat (best-effort 2s) =="
_timeout 2 bash -lc "curl -sS -N -H 'Accept: text/event-stream' '$BASE_URL/events/task-events' | sed -n '1,25p'" || true

echo "== create a trivial task (best-effort) =="
set +e
curl -sS -X POST "$BASE_URL/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{"title":"phase33-smoke","agent":"smoke","source":"smoke"}' | sed -n '1,160p'
rc=$?
set -e
echo "create_rc=$rc (nonzero may mean endpoint differs; smoke continues)"

echo "== quick db sanity (if psql + POSTGRES_URL are available) =="
if command -v psql >/dev/null 2>&1 && [[ -n "${POSTGRES_URL:-}" ]]; then
  PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -c "select count(*) as tasks_total from tasks;" || true
  PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1 -c "select kind, count(*) from task_events group by kind order by count(*) desc;" || true
else
  echo "psql/POSTGRES_URL not set; skipping DB sanity."
fi

echo "== Phase 33 smoke DONE =="
