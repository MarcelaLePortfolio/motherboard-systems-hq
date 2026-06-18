
#!/usr/bin/env bash

set -euo pipefail

echo "--- actual dbCompleteTask definition ---"

git grep -n "export async function dbCompleteTask" -- \

  server \

  server.mjs \

  scripts \

  smoke-db-complete-task-direct.mjs \

  ':!*.txt' \

  ':!*.md' \

  ':!backups/**' \

  ':!scripts_backup/**' \

  ':!scripts_backup_2/**' \

  ':!_dashboard_candidate_previews/**' \

  ':!DASHBOARD_UI_RECOVERY_ANCHORS/**' || true

echo

echo "--- actual runtime callers ---"

git grep -n "dbCompleteTask(" -- \

  server \

  server.mjs \

  scripts \

  smoke-db-complete-task-direct.mjs \

  ':!*.txt' \

  ':!*.md' \

  ':!backups/**' \

  ':!scripts_backup/**' \

  ':!scripts_backup_2/**' \

  ':!_dashboard_candidate_previews/**' \

  ':!DASHBOARD_UI_RECOVERY_ANCHORS/**' || true

echo

echo "--- completion route mount ---"

git grep -n "dbCompleteTask(pool" -- \

  server \

  server.mjs \

  scripts \

  smoke-db-complete-task-direct.mjs \

  ':!*.txt' \

  ':!*.md' \

  ':!backups/**' \

  ':!scripts_backup/**' \

  ':!scripts_backup_2/**' \

  ':!_dashboard_candidate_previews/**' \

  ':!DASHBOARD_UI_RECOVERY_ANCHORS/**' || true

echo

echo "--- phase26 worker completion section ---"

sed -n '160,260p' server/worker/phase26_task_worker.mjs

