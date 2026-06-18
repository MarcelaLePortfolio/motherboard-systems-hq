
#!/usr/bin/env bash

set -euo pipefail

echo "--- dbDelegateTask hardcoded queued status ---"

sed -n '45,90p' server/tasks-mutations.mjs

echo

echo "--- governed planning dbDelegateTask call ---"

sed -n '215,255p' server/routes/governed-planning-route.mjs

echo

echo "--- recent tasks status renderer ---"

sed -n '1,90p' public/js/phase565_recent_tasks_wire.js

git add inspect-planning-record-status-change-surfaces.sh

git commit -m "Add planning record status change inspection"

git push

