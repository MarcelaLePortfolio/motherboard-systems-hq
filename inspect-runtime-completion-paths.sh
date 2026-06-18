
#!/usr/bin/env bash

set -euo pipefail

SCOPE=(

  -- .

  ':!*.txt'

  ':!*.md'

  ':!inspect-runtime-completion-paths.sh'

  ':!backups/**'

  ':!scripts_backup/**'

  ':!scripts_backup_2/**'

  ':!_dashboard_candidate_previews/**'

  ':!DASHBOARD_UI_RECOVERY_ANCHORS/**'

  ':!exports/**'

  ':!snapshots/**'

)

echo "--- actual dbCompleteTask definition ---"

git grep -n "export async function dbCompleteTask" "${SCOPE[@]}" || true

echo

echo "--- actual runtime callers ---"

git grep -n "dbCompleteTask(" "${SCOPE[@]}" || true

echo

echo "--- completion route mount ---"

git grep -n "dbCompleteTask(pool" "${SCOPE[@]}" || true

echo

echo "--- phase26 worker completion section ---"

sed -n '160,260p' server/worker/phase26_task_worker.mjs

