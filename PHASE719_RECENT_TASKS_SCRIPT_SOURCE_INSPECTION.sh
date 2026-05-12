
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 RECENT TASKS SCRIPT SOURCE INSPECTION ====="

echo ""

for file in public/js/phase565_recent_tasks_wire.js public/js/task-events-sse-client.js public/js/phase531_recent_tasks_layout_fix.js public/js/phase457_restore_task_panels.js public/js/phase487_humanize_task_ids.js

do

  echo "--- $file ---"

  if [ -f "$file" ]; then

    grep -nE "recentTasks|innerHTML|Updated:|status=|taskRows|renderRecent|appendChild|insertAdjacentHTML" "$file" | head -80 || true

  else

    echo "missing"

  fi

  echo ""

done

echo "[cleanup] Remove committed dashboard HTML snapshot from repo"

git rm -f phase719_dom_inspection/dashboard.html || true

echo ""

echo "[status]"

git status --short

git add PHASE719_RECENT_TASKS_SCRIPT_SOURCE_INSPECTION.sh

git commit -m "Phase 719: inspect recent tasks script sources"

git push origin dev

