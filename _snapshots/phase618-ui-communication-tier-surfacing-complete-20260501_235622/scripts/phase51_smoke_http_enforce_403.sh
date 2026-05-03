#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

PGC="${PGC:-}"
if [[ -z "${PGC}" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n 1 || true)"
fi
if [[ -z "${PGC}" ]]; then
  echo "ERROR: could not auto-detect postgres container. Set PGC=..." >&2
  exit 2
fi

sql() { docker exec -i "$PGC" psql -v ON_ERROR_STOP=1 -U postgres -d postgres -Atc "$1"; }

echo "=== counts BEFORE ==="
t0="$(sql "select count(*) from tasks")"
e0="$(sql "select count(*) from task_events")"
echo "tasks=$t0 task_events=$e0"

echo
echo "=== POST /api/tasks/create under enforce (expect 403) ==="
code="$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/tasks/create" \
  -H "content-type: application/json" \
  --data '{"title":"phase51-smoke","agent":"cade","source":"smoke","trace_id":"phase51-smoke","actor":"smoke"}' || true)"
echo "HTTP=$code"
[[ "$code" == "403" ]] || { echo "FAIL: expected 403, got $code"; exit 3; }

echo
echo "=== counts AFTER ==="
t1="$(sql "select count(*) from tasks")"
e1="$(sql "select count(*) from task_events")"
echo "tasks=$t1 task_events=$e1"

echo
echo "=== assert unchanged ==="
[[ "$t1" == "$t0" ]] || { echo "FAIL: tasks changed ($t0 -> $t1)"; exit 4; }
[[ "$e1" == "$e0" ]] || { echo "FAIL: task_events changed ($e0 -> $e1)"; exit 5; }
echo "OK: HTTP path returns 403 and causes no DB writes under enforce."
