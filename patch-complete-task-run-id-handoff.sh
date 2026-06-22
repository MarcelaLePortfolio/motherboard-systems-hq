
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

path = Path("server/tasks-mutations.mjs")

text = path.read_text(encoding="utf-8")

old = '''  await emitTaskEvent({

    pool,

    kind: k,

    task_id: row.task_id ?? row.id,

    actor: body?.actor ?? body?.agent ?? payload.agent ?? body?.source ?? "api",

    payload: {

      status: row.status,

      error: body?.error ?? null,

      source: body?.source || payload.source || "api",

      task: row,

    },

  });'''

new = '''  await emitTaskEvent({

    pool,

    kind: k,

    task_id: row.task_id ?? row.id,

    run_id: body?.run_id ?? body?.runId ?? row.run_id ?? null,

    actor: body?.actor ?? body?.agent ?? payload.agent ?? body?.source ?? "api",

    payload: {

      status: row.status,

      error: body?.error ?? null,

      source: body?.source || payload.source || "api",

      task: row,

    },

  });'''

if old not in text:

    raise SystemExit("target emitTaskEvent completion block not found; refusing patch")

path.write_text(text.replace(old, new, 1), encoding="utf-8")

PY

git diff -- server/tasks-mutations.mjs

docker compose build dashboard

docker compose up -d dashboard

./smoke-current-task-mutations-with-runid.sh

git add server/tasks-mutations.mjs patch-complete-task-run-id-handoff.sh smoke-current-task-mutations-with-runid.sh

git commit -m "Pass run id through task completion event handoff"

git push

