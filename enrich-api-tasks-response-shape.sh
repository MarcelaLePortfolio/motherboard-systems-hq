
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PYTHONPATCH'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text(encoding="utf-8")

old = """    const r = await pool.query(

      `

      SELECT id, task_id, title, status, updated_at

      FROM tasks

      ORDER BY updated_at DESC NULLS LAST, id DESC

      LIMIT $1

      `,

      [limit]

    );"""

new = """    const r = await pool.query(

      `

      SELECT

        id,

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

        updated_at,

        coalesce(payload->>'agent', assignee) as agent,

        coalesce(payload->>'source', metadata->>'source') as source,

        coalesce(payload->>'trace_id', metadata->>'trace_id') as trace_id,

        coalesce(payload->'meta', metadata->'meta') as meta,

        coalesce(payload->'delegation_envelope', metadata->'delegation_envelope') as delegation_envelope,

        coalesce(payload->'artifacts', metadata->'artifacts') as artifacts,

        coalesce(payload->'artifact', metadata->'artifact') as artifact,

        coalesce(payload->>'outcome_preview', metadata->>'outcome_preview') as outcome_preview,

        coalesce(payload->>'explanation_preview', notes, metadata->>'explanation_preview') as explanation_preview,

        coalesce(payload->'guidance', metadata->'guidance') as guidance,

        coalesce(payload->>'strategy', metadata->>'strategy') as strategy,

        coalesce(payload->'meta'->>'retry_of_task_id', metadata->'meta'->>'retry_of_task_id') as retry_of_task_id

      FROM tasks

      ORDER BY updated_at DESC NULLS LAST, id DESC

      LIMIT $1

      `,

      [limit]

    );"""

if old not in text:

    raise SystemExit("target /api/tasks select block not found; refusing patch")

path.write_text(text.replace(old, new, 1), encoding="utf-8")

PYTHONPATCH

git diff -- server/routes/api-tasks-postgres.mjs

docker compose build dashboard

docker compose up -d dashboard

echo "===== VERIFY ENRICHED /api/tasks ====="

curl -sS "http://localhost:8080/api/tasks?limit=5" | python3 -m json.tool

echo

echo "===== DASHBOARD HEALTH ====="

curl -i http://localhost:8080/api/tasks/health

git add server/routes/api-tasks-postgres.mjs enrich-api-tasks-response-shape.sh

git commit -m "Enrich task list response for UI wiring"

git push

