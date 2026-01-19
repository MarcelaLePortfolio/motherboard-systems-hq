#!/usr/bin/env bash
set -euo pipefail
: "${POSTGRES_URL:?POSTGRES_URL required}"

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -qtAc "
select
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='payload') as has_tasks_payload,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='meta') as has_tasks_meta,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='attempt') as has_tasks_attempt,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='attempts') as has_tasks_attempts,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='available_at') as has_tasks_available_at,
  (select count(*) from information_schema.columns where table_name='tasks' and column_name='next_run_at') as has_tasks_next_run_at,
  (select count(*) from information_schema.columns where table_name='task_events' and column_name='payload') as has_events_payload,
  (select data_type from information_schema.columns where table_name='task_events' and column_name='payload') as events_payload_type,
  (select count(*) from information_schema.columns where table_name='task_events' and column_name='run_id') as has_events_run_id,
  (select count(*) from information_schema.columns where table_name='task_events' and column_name='actor') as has_events_actor
"
