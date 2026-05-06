#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Direct restore run_view schema"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Container state..."
docker compose ps

echo ""
echo "3) Creating run_view directly in Postgres..."
docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'
drop view if exists run_view;

create view run_view as
with latest_event as (
  select distinct on (te.task_id)
    te.task_id::text as task_id,
    te.id::bigint as last_event_id,
    te.ts::bigint as last_event_ts,
    te.kind::text as last_event_kind,
    coalesce(te.actor, 'unassigned')::text as actor,
    te.run_id::text as run_id
  from task_events te
  order by te.task_id, te.ts desc, te.id desc
),
terminal_event as (
  select distinct on (te.task_id)
    te.task_id::text as task_id,
    te.kind::text as terminal_event_kind,
    te.ts::bigint as terminal_event_ts,
    te.id::bigint as terminal_event_id
  from task_events te
  where te.kind in ('task.completed', 'task.failed', 'task.canceled')
  order by te.task_id, te.ts desc, te.id desc
)
select
  coalesce(le.run_id, t.run_id, t.task_id)::text as run_id,
  t.task_id::text as task_id,
  t.status::text as task_status,
  (t.status in ('completed', 'failed', 'canceled')) as is_terminal,
  le.last_event_id,
  le.last_event_ts,
  le.last_event_kind,
  coalesce(
    le.actor,
    t.payload->>'agent',
    t.payload->>'owner',
    t.payload->>'actor',
    'unassigned'
  )::text as actor,
  null::timestamptz as lease_expires_at,
  false as lease_fresh,
  null::bigint as lease_ttl_ms,
  null::bigint as last_heartbeat_ts,
  null::bigint as heartbeat_age_ms,
  te.terminal_event_kind,
  te.terminal_event_ts,
  te.terminal_event_id,
  t.id::text as id,
  t.status::text as status,
  t.updated_at,
  t.created_at,
  coalesce(
    t.payload->>'agent',
    t.payload->>'owner',
    t.payload->>'actor',
    'unassigned'
  )::text as agent
from tasks t
left join latest_event le on le.task_id = t.task_id
left join terminal_event te on te.task_id = t.task_id;
SQL

echo ""
echo "4) Verifying database relations..."
docker compose exec -T postgres psql -U postgres -d postgres -c "\dt"
docker compose exec -T postgres psql -U postgres -d postgres -c "\dv"

echo ""
echo "5) Verifying run_view query..."
docker compose exec -T postgres psql -U postgres -d postgres -c "select * from run_view limit 10;"

echo ""
echo "6) Probing inspector-backed API endpoints..."
for url in \
  "http://localhost:3000/api/health" \
  "http://localhost:3000/api/tasks?limit=12" \
  "http://localhost:3000/api/runs" \
  "http://localhost:3000/api/guidance"
do
  echo ""
  echo "---- $url ----"
  curl -i -sS --max-time 8 "$url" | sed -n '1,120p' || true
done

echo ""
echo "7) Git seal for direct run_view restoration..."
cat > PHASE704_DIRECT_RUN_VIEW_RESTORED.md << 'SEAL'
# Phase 704 — Direct run_view Restoration

The first run_view restoration attempt inspected the exported helper but did not invoke it.

This seal records direct restoration of the `run_view` schema through Postgres after the Docker data reset.

Verified:
- `run_view` was created directly in Postgres
- `\dv` lists `run_view`
- `select * from run_view limit 10` executes
- inspector-backed endpoints were probed after schema restoration
SEAL

git add PHASE704_DIRECT_RESTORE_RUN_VIEW_SCHEMA.sh PHASE704_DIRECT_RUN_VIEW_RESTORED.md
git commit -m "Phase 704: directly restore run_view schema"
git push

echo ""
echo "Phase 704 direct run_view restoration complete."
