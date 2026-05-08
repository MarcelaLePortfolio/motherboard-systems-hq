
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 EXECUTION SURFACE INSPECTION ====="

echo ""

echo "[1] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Locate Recent Tasks renderers/components"

find . \

  -path "./node_modules" -prune -o \

  -path "./.next" -prune -o \

  -path "./.git" -prune -o \

  -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.js" -o -name "*.jsx" -o -name "*.html" \) \

  -print | xargs grep -nEi "Recent Tasks|recent tasks|recentTasks|task card|task-card|TaskHistory|Task History|Execution Inspector|execution inspector" || true

echo ""

echo "[3] Locate retry/requeue endpoints and handlers"

find . \

  -path "./node_modules" -prune -o \

  -path "./.next" -prune -o \

  -path "./.git" -prune -o \

  -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.js" -o -name "*.jsx" -o -name "*.html" \) \

  -print | xargs grep -nEi "retry|requeue|rerun|restart|/api/tasks|task_events|task-events" || true

echo ""

echo "[4] Inspect public renderer bridge if present"

if [ -f public/js/phase530_visible_panels_bridge.js ]; then

  sed -n '1,260p' public/js/phase530_visible_panels_bridge.js

else

  echo "public/js/phase530_visible_panels_bridge.js not found"

fi

echo ""

echo "[5] Inspect task API routes"

find app pages src server lib public -path "./node_modules" -prune -o -type f 2>/dev/null | grep -Ei "(api|route|task|execution)" | sort || true

echo ""

echo "[6] Runtime containers"

docker compose ps || true

echo ""

echo "===== PHASE 717 INSPECTION COMPLETE ====="

