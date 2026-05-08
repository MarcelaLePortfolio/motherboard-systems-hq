
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 TARGETED DISCOVERY v2 ====="

echo ""

SEARCH_ROOTS="routes app src components public ."

EXCLUDES=(-path "./node_modules" -o -path "./.git" -o -path "./.next" -o -path "./ts-backup")

search_files() {

  local pattern="$1"

  find . \

    \( -path "./node_modules" -o -path "./.git" -o -path "./.next" -o -path "./ts-backup" \) -prune -o \

    -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" -o -name "*.html" -o -name "*.mjs" -o -name "*.cjs" \) \

    -print0 | xargs -0 grep -nEi "$pattern" || true

}

echo "[1] Locate actual Recent Tasks UI implementations"

search_files "Recent Tasks|recent tasks|recentTasks|task history|Task History|Execution Inspector|execution inspector"

echo ""

echo "[2] Locate retry/requeue implementations"

search_files "retry differently|retryDifferently|requeue|retry|rerun|restart"

echo ""

echo "[3] Locate API task route handlers"

search_files "router\.(post|get)|app\.(post|get)|/api/tasks|task_events|run_view"

echo ""

echo "[4] Inspect authoritative task route candidates"

for file in \

  routes/api/tasks.ts \

  routes/tasks.ts \

  app/api/tasks/route.ts \

  app/api/tasks/retry/route.ts \

  app/api/tasks/requeue/route.ts

do

  if [ -f "$file" ]; then

    echo ""

    echo "----- $file -----"

    sed -n '1,320p' "$file"

  fi

done

echo ""

echo "[5] Inspect renderer bridge"

if [ -f public/js/phase530_visible_panels_bridge.js ]; then

  echo "----- public/js/phase530_visible_panels_bridge.js -----"

  sed -n '1,420p' public/js/phase530_visible_panels_bridge.js

else

  echo "public/js/phase530_visible_panels_bridge.js not found"

fi

echo ""

echo "[6] Inspect dashboard/component candidates"

find . \

  \( -path "./node_modules" -o -path "./.git" -o -path "./.next" -o -path "./ts-backup" \) -prune -o \

  -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" -o -name "*.html" \) \

  -print | grep -Ei "(dashboard|task|inspector|history|guidance|operator|phase530|visible_panels)" | sort || true

echo ""

echo "[7] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "===== PHASE 717 TARGETED DISCOVERY v2 COMPLETE ====="

