
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="FRESH_TASK_EVENTS_SCHEMA_DASHBOARD_REPAIR.txt"

rm -f "$OUTPUT"

{

  echo "===== FRESH TASK EVENTS SCHEMA DASHBOARD REPAIR ====="

  date

  echo

  echo "===== CURRENT TASK_EVENTS COLUMNS ====="

  docker compose exec -T postgres psql -U postgres -d postgres -c "\d+ task_events"

  echo

  echo "===== APPLY NARROW COMPATIBILITY REPAIR ====="

  docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'

ALTER TABLE public.task_events ADD COLUMN IF NOT EXISTS kind TEXT;

ALTER TABLE public.task_events ADD COLUMN IF NOT EXISTS run_id TEXT;

ALTER TABLE public.task_events ADD COLUMN IF NOT EXISTS actor TEXT;

ALTER TABLE public.task_events ADD COLUMN IF NOT EXISTS ts BIGINT DEFAULT (extract(epoch from now()) * 1000)::bigint;

CREATE INDEX IF NOT EXISTS task_events_kind_idx ON public.task_events(kind);

CREATE INDEX IF NOT EXISTS task_events_task_id_idx ON public.task_events(task_id);

CREATE INDEX IF NOT EXISTS task_events_ts_idx ON public.task_events(ts);

SQL

  echo

  echo "===== UPDATED TASK_EVENTS COLUMNS ====="

  docker compose exec -T postgres psql -U postgres -d postgres -c "\d+ task_events"

  echo

  echo "===== RESTART DASHBOARD ====="

  docker compose restart dashboard

  sleep 8

  docker compose ps

  echo

  echo "===== BASELINE HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== TASK EVENTS SSE TIMEBOXED CHECK ====="

  curl -i --max-time 2 http://localhost:8080/events/task-events || true

  echo

  echo "===== DASHBOARD ROOT ====="

  curl -I http://localhost:8080/

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add repair-fresh-task-events-schema-for-dashboard.sh FRESH_TASK_EVENTS_SCHEMA_DASHBOARD_REPAIR.txt

git commit -m "Repair fresh task events schema for dashboard" || true

git push

