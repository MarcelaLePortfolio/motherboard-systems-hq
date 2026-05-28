
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

path = Path("server/tasks-mutations.mjs")

text = path.read_text(encoding="utf-8")

old = '''    task_id: row.task_id ?? row.id,

    actor: body?.actor ?? body?.agent ?? payload.agent ?? body?.source ?? "api",'''

new = '''    task_id: row.task_id ?? row.id,

    run_id: body?.run_id ?? body?.runId ?? row.run_id ?? null,

    actor: body?.actor ?? body?.agent ?? payload.agent ?? body?.source ?? "api",'''

if old not in text:

    raise SystemExit("target completion event handoff not found")

path.write_text(text.replace(old, new, 1), encoding="utf-8")

PY

git diff -- server/tasks-mutations.mjs

docker compose build dashboard

docker compose up -d dashboard

./rebuild-and-run-direct-db-smoke.sh

git add server/tasks-mutations.mjs patch-db-complete-run-id-directly.sh

git commit -m "Pass run id from dbCompleteTask to completion event"

git push

