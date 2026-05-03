#!/usr/bin/env bash
set -euo pipefail

POSTGRES_CONTAINER="motherboard_systems_hq-postgres-1"

docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<SQL
insert into task_events (task_id, kind, actor, payload, run_id, ts)
values (
  '\''phase489-demo-task'\'',
  '\''task.created'\'',
  '\''operator'\'',
  '\''{"title":"Phase 489 telemetry validation event","message":"Synthetic task event inserted to validate Task Events panel","status":"created","source":"phase489-h2-seed"}'\''::jsonb,
  '\''phase489-demo-run'\'',
  (extract(epoch from now()) * 1000)::bigint
);
SQL
'

echo "Inserted one synthetic task_event row for telemetry validation."
