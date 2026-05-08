
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 GIT-GREP DISCOVERY ====="

echo ""

git_grep_bounded() {

  local title="$1"

  local pattern="$2"

  echo "$title"

  set +o pipefail

  git grep -nEi "$pattern" -- \

    . \

    ':(exclude)ts-backup/**' \

    ':(exclude)node_modules/**' \

    ':(exclude).next/**' \

    ':(exclude).git/**' \

    ':(exclude)backups/**' \

    ':(exclude)PHASE717_TARGETED_DISCOVERY_RESULT.txt' \

    ':(exclude)PHASE717_EXECUTION_SURFACE_INSPECTION_RESULT.txt' \

    | head -n 160

  set -o pipefail

  echo ""

}

git_grep_bounded "[1] Recent Tasks / Task History / Execution Inspector matches" \

  "Recent Tasks|recent tasks|recentTasks|Task History|task history|Execution Inspector|execution inspector"

git_grep_bounded "[2] Retry / requeue matches" \

  "retry differently|retryDifferently|requeue|retry|rerun|restart"

git_grep_bounded "[3] Task API / event / run_view matches" \

  "/api/tasks|task_events|task-events|run_view|router\\.(post|get)|app\\.(post|get)"

echo "[4] Concrete files"

for file in \

  routes/api/tasks.ts \

  routes/tasks.ts \

  public/js/phase530_visible_panels_bridge.js \

  app/api/tasks/route.ts \

  app/api/tasks/retry/route.ts \

  app/api/tasks/requeue/route.ts

do

  if [ -f "$file" ]; then

    echo ""

    echo "----- $file -----"

    sed -n '1,220p' "$file"

  fi

done

echo ""

echo "[5] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "===== PHASE 717 GIT-GREP DISCOVERY COMPLETE ====="

