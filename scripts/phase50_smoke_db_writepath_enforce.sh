#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
PGC="${PGC:-motherboard_systems_hq-postgres-1}"

sql() {
  docker exec -i "$PGC" psql -v ON_ERROR_STOP=1 -U postgres -d postgres -Atc "$1"
}

echo "=== counts BEFORE ==="
t0="$(sql "select count(*) from tasks")"
e0="$(sql "select count(*) from task_events")"
echo "tasks=$t0 task_events=$e0"

echo
echo "=== attempt write under enforce (expect 403-ish; counts must not change) ==="
code="$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/tasks" \
  -H "content-type: application/json" --data '{}' || true)"
echo "POST /api/tasks => $code"

echo
echo "=== counts AFTER ==="
t1="$(sql "select count(*) from tasks")"
e1="$(sql "select count(*) from task_events")"
echo "tasks=$t1 task_events=$e1"

echo
echo "=== assert unchanged ==="
[[ "$t1" == "$t0" ]] || { echo "FAIL: tasks changed ($t0 -> $t1)"; exit 2; }
[[ "$e1" == "$e0" ]] || { echo "FAIL: task_events changed ($e0 -> $e1)"; exit 3; }
echo "OK: no DB writes under enforce."
