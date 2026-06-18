
#!/usr/bin/env bash

set -euo pipefail

printf '\n--- inspect discovered task worker ---\n'

sed -n '1,280p' server/worker/phase26_task_worker.mjs

printf '\n--- inspect worker references ---\n'

git grep -nE "phase26_task_worker|task_worker|worker/phase26|task.completed|task.failed|retry_scheduled|lease|queued|running" server scripts docs | head -n 260

printf '\n--- inspect worker route/schema dependencies ---\n'

git grep -nE "lease|retry_scheduled|attempt|task.started|task.running|worker" server | head -n 260

printf '\n--- verify latest commits ---\n'

git log --oneline -10

