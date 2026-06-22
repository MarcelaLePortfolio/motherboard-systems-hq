
#!/usr/bin/env bash

set -euo pipefail

echo

echo "--- governed planning task creation ---"

grep -n "kind: \"governed_planning\"" server/routes/governed-planning-route.mjs

echo

echo "--- task completion entrypoints ---"

grep -n "dbCompleteTask" \

  server/routes/api-tasks-mutations.mjs \

  server/tasks-mutations.mjs \

  server/worker/phase26_task_worker.mjs

