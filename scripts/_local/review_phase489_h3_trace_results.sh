#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
TRACE="$ROOT/docs/PHASE_489_H3_TASK_EVENT_PRODUCTION_PATH_TRACE.txt"

echo "=== TRACE FILE EXISTS ==="
ls -l "$TRACE"

echo
echo "=== POST RESULT SECTIONS ==="
grep -nE '=== EXERCISE REAL TASK CREATION PATH ===|POST /api/tasks-mutations/delegate|POST /api/tasks-mutations/delegate-taskspec|=== TASK_EVENTS COUNT AFTER REAL MUTATION ATTEMPTS ===|=== LATEST 20 TASK_EVENTS ===|=== LIVE TASK ROWS ===' "$TRACE" || true

echo
echo "=== TRACE EXCERPT AROUND MUTATION RESULTS ==="
awk '
/=== EXERCISE REAL TASK CREATION PATH ===/ {show=1}
show {print}
(/=== NEXT ACTION ===/) {show=0}
' "$TRACE" | sed -n '1,260p'

echo
echo "=== CURRENT TASK_EVENTS COUNT (LIVE DB) ==="
docker exec -i motherboard_systems_hq-postgres-1 sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "select count(*) from task_events;"
'

echo
echo "=== CURRENT LATEST 20 TASK_EVENTS (LIVE DB) ==="
docker exec -i motherboard_systems_hq-postgres-1 sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "
select
  coalesce(to_char(created_at at time zone '\''UTC'\'', '\''YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'\''), '\''—'\'') || '\'' | '\'' ||
  coalesce(kind, '\''—'\'') || '\'' | task='\'' || coalesce(task_id, '\''—'\'') || '\'' | actor='\'' || coalesce(actor, '\''—'\'') || '\'' | run='\'' || coalesce(run_id, '\''—'\'')
from task_events
order by ts desc, id desc
limit 20;
"
'

echo
echo "=== CURRENT TASKS (LIVE API) ==="
curl -s http://localhost:8080/api/tasks | sed -n '1,200p'
