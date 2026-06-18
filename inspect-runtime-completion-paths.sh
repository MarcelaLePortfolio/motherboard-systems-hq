
#!/usr/bin/env bash

set -euo pipefail

echo "--- actual dbCompleteTask definition ---"

grep -R -n --include="*.mjs" --include="*.js" \

  "export async function dbCompleteTask" server .

echo

echo "--- actual runtime callers ---"

grep -R -n --include="*.mjs" --include="*.js" \

  "dbCompleteTask(" server .

echo

echo "--- completion route mount ---"

grep -R -n --include="*.mjs" --include="*.js" \

  "dbCompleteTask(pool" server .

echo

echo "--- phase26 worker completion section ---"

sed -n '160,260p' server/worker/phase26_task_worker.mjs

