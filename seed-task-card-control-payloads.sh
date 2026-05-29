
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="task-card-control-payload-seed-${STAMP}.md"

PGUSER_IN_CONTAINER="$(docker compose exec -T postgres printenv POSTGRES_USER 2>/dev/null || true)"

PGDB_IN_CONTAINER="$(docker compose exec -T postgres printenv POSTGRES_DB 2>/dev/null || true)"

PGUSER_IN_CONTAINER="${PGUSER_IN_CONTAINER:-postgres}"

PGDB_IN_CONTAINER="${PGDB_IN_CONTAINER:-${PGUSER_IN_CONTAINER}}"

cat > /tmp/task-card-control-payload.sql << 'SQL'

insert into tasks (

  task_id,

  title,

  status,

  notes,

  run_id,

  action_tier,

  kind,

  payload,

  metadata,

  created_at,

  updated_at

)

values (

  'task-card-controls-visible-smoke',

  'Task card controls visible smoke',

  'done',

  'Smoke row seeded to verify Preview, Inspect trace, and Inspect logs pills.',

  'task-card-controls-visible-smoke',

  'A',

  'delegated',

  '{

    "agent": "cade",

    "source": "task_card_controls_smoke",

    "artifact": {

      "filename": "task-card-controls-smoke.md",

      "path": "ARTIFACTS/task-card-controls-smoke.md",

      "type": "markdown",

      "size_bytes": 512

    },

    "trace": {

      "phase": "task-card-control-smoke",

      "status": "done",

      "reason": "payload includes trace data for Inspect trace pill"

    },

    "logs": [

      "seeded control visibility smoke task",

      "artifact payload present",

      "trace payload present",

      "logs payload present"

    ],

    "outcome_preview": "Task card control smoke completed.",

    "explanation_preview": "This row intentionally includes artifact, trace, and logs payloads so the task card controls can render."

  }'::jsonb,

  '{}'::jsonb,

  now(),

  now()

)

on conflict (task_id) do update set

  title = excluded.title,

  status = excluded.status,

  notes = excluded.notes,

  run_id = excluded.run_id,

  action_tier = excluded.action_tier,

  kind = excluded.kind,

  payload = excluded.payload,

  metadata = excluded.metadata,

  updated_at = now();

SQL

docker compose exec -T postgres psql -U "$PGUSER_IN_CONTAINER" -d "$PGDB_IN_CONTAINER" < /tmp/task-card-control-payload.sql

{

  echo "# Task Card Control Payload Seed"

  echo

  echo "Postgres user: $PGUSER_IN_CONTAINER"

  echo "Postgres database: $PGDB_IN_CONTAINER"

  echo "Seeded task_id: task-card-controls-visible-smoke"

  echo

  echo "Expected visible controls:"

  echo "- Preview"

  echo "- Inspect trace"

  echo "- Inspect logs"

  echo

  echo "Open: http://localhost:8080/?v=task-card-controls-visible-smoke"

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" seed-task-card-control-payloads.sh

git commit -m "Seed task card control payload smoke"

git push

