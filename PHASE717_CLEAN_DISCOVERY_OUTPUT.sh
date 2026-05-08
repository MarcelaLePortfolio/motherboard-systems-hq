
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 CLEAN DISCOVERY OUTPUT ====="

cat > PHASE717_TARGETED_DISCOVERY.sh << 'EOS'

#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 TARGETED DISCOVERY v3 ====="

echo ""

search_files() {

  local label="$1"

  local pattern="$2"

  echo "$label"

  find . \

    \( \

      -path "./node_modules" -o \

      -path "./.git" -o \

      -path "./.next" -o \

      -path "./ts-backup" -o \

      -path "./backups" \

    \) -prune -o \

    -type f \( \

      -name "*.tsx" -o \

      -name "*.ts" -o \

      -name "*.jsx" -o \

      -name "*.js" -o \

      -name "*.html" -o \

      -name "*.mjs" -o \

      -name "*.cjs" \

    \) \

    -print0 | xargs -0 grep -nEi "$pattern" | head -n 220 || true

  echo ""

}

search_files "[1] Locate actual Recent Tasks UI implementations" "Recent Tasks|recent tasks|recentTasks|task history|Task History|Execution Inspector|execution inspector"

search_files "[2] Locate retry/requeue implementations" "retry differently|retryDifferently|requeue|retry|rerun|restart"

search_files "[3] Locate API task route handlers" "router\.(post|get)|app\.(post|get)|/api/tasks|task_events|run_view"

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

    sed -n '1,220p' "$file"

  fi

done

echo ""

echo "[5] Inspect renderer bridge"

if [ -f public/js/phase530_visible_panels_bridge.js ]; then

  echo "----- public/js/phase530_visible_panels_bridge.js -----"

  sed -n '1,260p' public/js/phase530_visible_panels_bridge.js

else

  echo "public/js/phase530_visible_panels_bridge.js not found"

fi

echo ""

echo "[6] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "===== PHASE 717 TARGETED DISCOVERY v3 COMPLETE ====="

EOS

chmod +x PHASE717_TARGETED_DISCOVERY.sh

cat > PHASE717_TARGETED_DISCOVERY_RESULT.txt << 'EOS'

PHASE 717 TARGETED DISCOVERY RESULT

Prior result was intentionally cleared because it captured excessive repository output.

Run ./PHASE717_TARGETED_DISCOVERY.sh again for bounded, macOS-safe discovery output.

EOS

git add PHASE717_CLEAN_DISCOVERY_OUTPUT.sh PHASE717_TARGETED_DISCOVERY.sh PHASE717_TARGETED_DISCOVERY_RESULT.txt

git commit -m "Phase 717: clean oversized discovery output"

git push origin dev

echo "===== PHASE 717 CLEAN DISCOVERY OUTPUT COMPLETE ====="

