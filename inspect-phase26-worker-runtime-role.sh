
#!/usr/bin/env bash

set -euo pipefail

echo "--- phase26 worker imports and config ---"

sed -n '1,80p' server/worker/phase26_task_worker.mjs

echo

echo "--- phase26 worker selection / lease section ---"

sed -n '80,170p' server/worker/phase26_task_worker.mjs

echo

echo "--- phase26 worker terminal marking helpers ---"

grep -nE "function markSuccess|async function markSuccess|function markFailure|async function markFailure|shouldFailDeterministically|lease|next_run_at|attempts" server/worker/phase26_task_worker.mjs

echo

echo "--- phase26 worker startup references ---"

git grep -n "phase26_task_worker" -- . ':!backups/**' ':!scripts_backup/**' ':!scripts_backup_2/**' || true

git add inspect-phase26-worker-runtime-role.sh

git commit -m "Add Phase 26 worker runtime role inspection"

git push

