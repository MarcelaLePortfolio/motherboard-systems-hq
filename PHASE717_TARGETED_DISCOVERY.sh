
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 TARGETED DISCOVERY ====="

echo ""

echo "[1] Locate actual Recent Tasks UI implementations"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=ts-backup \

  -E "Recent Tasks|recent tasks|recentTasks|task history|Execution Inspector|execution inspector" \

  . || true

echo ""

echo "[2] Locate retry/requeue implementations"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=ts-backup \

  -E "retry differently|retryDifferently|requeue|retry|rerun|restart" \

  . || true

echo ""

echo "[3] Locate API task route handlers"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=ts-backup \

  -E "router\.(post|get)|app\.(post|get)|/api/tasks|task_events|run_view" \

  routes app src . || true

echo ""

echo "[4] Inspect authoritative task route"

if [ -f routes/api/tasks.ts ]; then

  echo "----- routes/api/tasks.ts -----"

  sed -n '1,260p' routes/api/tasks.ts

fi

echo ""

echo "[5] Inspect renderer bridge"

if [ -f public/js/phase530_visible_panels_bridge.js ]; then

  echo "----- public/js/phase530_visible_panels_bridge.js -----"

  sed -n '1,320p' public/js/phase530_visible_panels_bridge.js

fi

echo ""

echo "[6] Inspect dashboard component tree"

find src app components public \

  -path "./node_modules" -prune -o \

  -path "./.next" -prune -o \

  -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" \) \

  | grep -Ei "(dashboard|task|inspector|history|guidance|operator)" \

  | sort || true

echo ""

echo "===== PHASE 717 TARGETED DISCOVERY COMPLETE ====="

