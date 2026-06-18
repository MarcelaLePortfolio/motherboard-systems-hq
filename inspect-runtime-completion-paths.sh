
#!/usr/bin/env bash

set -euo pipefail

echo "--- actual dbCompleteTask definition ---"

find . -type f \( -name "*.mjs" -o -name "*.js" \) \

  | xargs grep -n "export async function dbCompleteTask" || true

echo

echo "--- actual runtime callers ---"

find . -type f \( -name "*.mjs" -o -name "*.js" \) \

  | xargs grep -n "dbCompleteTask(" || true

echo

echo "--- completion route mount ---"

find . -type f \( -name "*.mjs" -o -name "*.js" \) \

  | xargs grep -n "dbCompleteTask(pool" || true

echo

echo "--- phase26 worker completion section ---"

sed -n '160,260p' server/worker/phase26_task_worker.mjs

