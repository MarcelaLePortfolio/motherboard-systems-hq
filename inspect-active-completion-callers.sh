
#!/usr/bin/env bash

set -euo pipefail

echo "--- active dbCompleteTask callers only ---"

git grep -n "dbCompleteTask" -- \

  server.mjs \

  server \

  scripts \

  smoke-db-complete-task-direct.mjs \

  ':!*.txt' \

  ':!*.md'

echo

echo "--- worker terminal event emitters ---"

sed -n '160,235p' server/worker/phase26_task_worker.mjs

