
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 GIT-GREP DISCOVERY v3 ====="

echo ""

git_grep_bounded() {

  local title="$1"

  local pattern="$2"

  echo "$title"

  git grep -nEi "$pattern" -- \

    routes \

    src/components \

    public \

    app 2>/dev/null \

    | grep -v "ts-backup" \

    | head -n 40 || true

  echo ""

}

git_grep_bounded "[1] Recent Tasks / Inspector matches" \

"Recent Tasks|recentTasks|Execution Inspector|task history"

git_grep_bounded "[2] Retry / requeue matches" \

"retry differently|retryDifferently|requeue|retry"

git_grep_bounded "[3] Task API matches" \

"/api/tasks|task_events|run_view"

echo "[4] Minimal concrete file previews"

for file in \

  routes/api/tasks.ts \

  routes/tasks.ts \

  public/js/phase530_visible_panels_bridge.js

do

  if [ -f "$file" ]; then

    echo ""

    echo "----- $file -----"

    sed -n '1,80p' "$file"

  fi

done

echo ""

echo "[5] Git state"

git status --short

git log --oneline --decorate -3

echo ""

echo "===== PHASE 717 GIT-GREP DISCOVERY v3 COMPLETE ====="

