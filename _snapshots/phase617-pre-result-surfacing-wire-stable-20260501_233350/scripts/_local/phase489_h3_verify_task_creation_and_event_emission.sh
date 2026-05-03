#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H3_VERIFY_TASK_CREATION_AND_EVENT_EMISSION.txt"
POSTGRES_CONTAINER="motherboard_systems_hq-postgres-1"

before_tasks_json="$(curl -s http://localhost:8080/api/tasks || true)"
before_tasks="$(printf '%s' "$before_tasks_json" | python3 -c 'import sys,json; raw=sys.stdin.read().strip() or "{}"; 
try:
 obj=json.loads(raw); tasks=obj.get("tasks") if isinstance(obj,dict) else []
 print(len(tasks) if isinstance(tasks,list) else 0)
except Exception:
 print(0)')"

before_events="$(
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "select count(*) from task_events;"
' 2>/dev/null || echo "0"
)"

delegate_response="$(
  curl -i -s -X POST http://localhost:8080/api/tasks-mutations/delegate \
    -H 'Content-Type: application/json' \
    --data '{"title":"Phase 489 H3 delegate verify task","agent":"Cade","notes":"Verify dbDelegateTask after tasks.run_id bootstrap","source":"phase489-h3-verify"}' || true
)"

taskspec_response="$(
  curl -i -s -X POST http://localhost:8080/api/tasks-mutations/delegate-taskspec \
    -H 'Content-Type: application/json' \
    --data '{"title":"Phase 489 H3 taskspec verify task","task":{"title":"Phase 489 H3 taskspec verify task","agent":"Effie","notes":"Verify delegate-taskspec after tasks.run_id bootstrap","source":"phase489-h3-verify"}}' || true
)"

after_tasks_json="$(curl -s http://localhost:8080/api/tasks || true)"
after_tasks="$(printf '%s' "$after_tasks_json" | python3 -c 'import sys,json; raw=sys.stdin.read().strip() or "{}"; 
try:
 obj=json.loads(raw); tasks=obj.get("tasks") if isinstance(obj,dict) else []
 print(len(tasks) if isinstance(tasks,list) else 0)
except Exception:
 print(0)')"

after_events="$(
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "select count(*) from task_events;"
' 2>/dev/null || echo "0"
)"

{
  echo "PHASE 489 — H3 VERIFY TASK CREATION AND EVENT EMISSION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== COUNTS BEFORE ==="
  echo "Tasks API count: $before_tasks"
  echo "task_events count: $before_events"
  echo

  echo "=== POST /api/tasks-mutations/delegate ==="
  printf '%s\n' "$delegate_response"
  echo

  echo "=== POST /api/tasks-mutations/delegate-taskspec ==="
  printf '%s\n' "$taskspec_response"
  echo

  echo "=== COUNTS AFTER ==="
  echo "Tasks API count: $after_tasks"
  echo "task_events count: $after_events"
  echo

  echo "=== LIVE TASKS API ==="
  printf '%s\n' "$after_tasks_json" | sed -n '1,220p'
  echo

  echo "=== LATEST 20 TASK_EVENTS ==="
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "
select
  coalesce(to_char(created_at at time zone '\''UTC'\'', '\''YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'\''), '\''—'\'') || '\'' | '\'' ||
  coalesce(kind, '\''—'\'') || '\'' | task='\'' || coalesce(task_id, '\''—'\'') || '\'' | actor='\'' || coalesce(actor, '\''—'\'') || '\'' | run='\'' || coalesce(run_id, '\''—'\'')
from task_events
order by ts desc, id desc
limit 20;
"
' || true
  echo

  echo "=== NEXT ACTION ==="
  echo "If tasks and task_events both increase, production path is restored."
  echo "If task creation still fails, inspect next missing tasks schema column from the error."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
