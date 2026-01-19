#!/usr/bin/env bash
set -euo pipefail
: "${POSTGRES_URL:?POSTGRES_URL required}"

row="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -qtAc "
select
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='payload')::int as has_tasks_payload,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='meta')::int as has_tasks_meta,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='attempt')::int as has_tasks_attempt,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='attempts')::int as has_tasks_attempts,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='available_at')::int as has_tasks_available_at,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='next_run_at')::int as has_tasks_next_run_at,
  (select (select data_type from information_schema.columns where table_name='task_events' and column_name='payload')::text) as events_payload_type,
  (select count(*) from information_schema.columns where table_name='task_events' and column_name='payload_jsonb')::int as has_events_payload_jsonb,
  (select count(*) from information_schema.columns where table_name='task_events' and column_name='run_id')::int as has_events_run_id,
  (select count(*) from information_schema.columns where table_name='task_events' and column_name='actor')::int as has_events_actor
")
IFS='|' read -r t_payload t_meta t_attempt t_attempts t_avail t_next ev_payload_type ev_payload_jsonb ev_run ev_actor <<<"$row"

echo "=== Phase30 DB Doctor (pretty) ==="
echo "tasks.payload:      ${t_payload}"
echo "tasks.meta:         ${t_meta}"
echo "tasks.attempt:      ${t_attempt}"
echo "tasks.attempts:     ${t_attempts}"
echo "tasks.available_at: ${t_avail}"
echo "tasks.next_run_at:  ${t_next}"
echo
echo "task_events.payload type: ${ev_payload_type:-<missing>}"
echo "task_events.payload_jsonb: ${ev_payload_jsonb}"
echo "task_events.run_id:        ${ev_run}"
echo "task_events.actor:         ${ev_actor}"
echo
if [ "${ev_payload_jsonb}" -ge 1 ]; then
  echo "status: CANONICAL-READY (dual-write supported)"
else
  echo "status: LEGACY (text-only events; run phase29 migration)"
fi
