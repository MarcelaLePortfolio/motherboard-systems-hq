#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H3_TASK_EVENT_PRODUCTION_PATH_TRACE.txt"
POSTGRES_CONTAINER="motherboard_systems_hq-postgres-1"

{
  echo "PHASE 489 — H3 TASK EVENT PRODUCTION PATH TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== GOAL ==="
  echo "Determine why the task_events stream is sparse by tracing whether real mutation paths"
  echo "actually emit rows into task_events."
  echo

  echo "=== SERVER EMIT PATH FILES ==="
  grep -RInE 'emitTaskEvent|appendTaskEvent|task_events|task-events|dbDelegateTask|dbCompleteTask' "$ROOT/server" \
    --include="*.js" --include="*.mjs" --include="*.ts" | sed -n '1,240p' || true
  echo

  for f in \
    "$ROOT/server/task_events_emit.mjs" \
    "$ROOT/server/task-events.mjs" \
    "$ROOT/server/tasks-mutations.mjs" \
    "$ROOT/server/api/tasks-mutations/delegate-taskspec.mjs"
  do
    if [[ -f "$f" ]]; then
      echo "=== FILE: $f ==="
      sed -n '1,260p' "$f"
      echo
    fi
  done

  echo "=== BASELINE TASK_EVENTS COUNT ==="
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "select count(*) from task_events;"
' || true
  echo

  echo "=== EXERCISE REAL TASK CREATION PATH ==="
  CREATE_PAYLOAD='{"title":"Phase 489 H3 real mutation trace task","agent":"Cade","notes":"Trace whether dbDelegateTask emits task_events","source":"phase489-h3-trace"}'
  echo "POST /api/tasks-mutations/delegate"
  curl -i -s -X POST http://localhost:8080/api/tasks-mutations/delegate \
    -H 'Content-Type: application/json' \
    --data "$CREATE_PAYLOAD" | sed -n '1,160p' || true
  echo

  echo "POST /api/tasks-mutations/delegate-taskspec"
  TASKSPEC_PAYLOAD='{"title":"Phase 489 H3 taskspec trace task","task":{"title":"Phase 489 H3 taskspec trace task","agent":"Effie","notes":"Trace whether delegate-taskspec emits task_events","source":"phase489-h3-trace"}}'
  curl -i -s -X POST http://localhost:8080/api/tasks-mutations/delegate-taskspec \
    -H 'Content-Type: application/json' \
    --data "$TASKSPEC_PAYLOAD" | sed -n '1,200p' || true
  echo

  echo "=== TASK_EVENTS COUNT AFTER REAL MUTATION ATTEMPTS ==="
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "select count(*) from task_events;"
' || true
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

  echo "=== LIVE TASK ROWS ==="
  curl -s http://localhost:8080/api/tasks | sed -n '1,200p' || true
  echo

  echo "=== NEXT ACTION ==="
  echo "If task creation succeeds but task_events count does not grow, the emission path is broken."
  echo "If creation itself fails, fix the mutation route first."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
