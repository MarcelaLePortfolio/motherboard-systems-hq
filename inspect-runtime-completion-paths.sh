
#!/usr/bin/env bash

set -euo pipefail

filter_active_paths() {

  grep -Ev '(^|/)(backups|scripts_backup|scripts_backup_2|_dashboard_candidate_previews|DASHBOARD_UI_RECOVERY_ANCHORS|exports|snapshots)/' || true

}

echo "--- actual dbCompleteTask definition ---"

git grep -n "export async function dbCompleteTask" -- '*.mjs' '*.js' | filter_active_paths

echo

echo "--- actual runtime callers ---"

git grep -n "dbCompleteTask(" -- '*.mjs' '*.js' | filter_active_paths

echo

echo "--- completion route mount ---"

git grep -n "dbCompleteTask(pool" -- '*.mjs' '*.js' | filter_active_paths

echo

echo "--- phase26 worker completion section ---"

sed -n '160,260p' server/worker/phase26_task_worker.mjs

