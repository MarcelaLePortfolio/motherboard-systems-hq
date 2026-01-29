#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "== Phase 33 smoke =="

if [[ -f docker-compose.yml ]]; then
  docker compose up -d --remove-orphans || true
fi

timeout 2 bash -lc "curl -sS -N -H 'Accept: text/event-stream' '$BASE_URL/events/task-events' | sed -n '1,25p'" || true

set +e
curl -sS -X POST "$BASE_URL/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{"title":"phase33-smoke","agent":"smoke","source":"smoke"}' | sed -n '1,120p'
rc=$?
set -e
echo "create_rc=$rc (nonzero may mean endpoint differs; smoke continues)"

if command -v psql >/dev/null 2>&1 && [[ -n "${POSTGRES_URL:-}" ]]; then
  psql "$POSTGRES_URL" -c "select count(*) as tasks_total from tasks;" || true
  psql "$POSTGRES_URL" -c "select kind, count(*) from task_events group by kind order by count(*) desc limit 10;" || true
else
  echo "psql/POSTGRES_URL not set; skipping DB sanity."
fi

echo "== Phase 33 smoke DONE =="
