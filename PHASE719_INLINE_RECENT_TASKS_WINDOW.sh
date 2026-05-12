
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 INLINE RECENT TASKS WINDOW ====="

echo ""

for file in public/index.html public/dashboard.html; do

  echo "--- $file ---"

  if [ -f "$file" ]; then

    grep -n "Status:" "$file" | head -10 || true

    grep -n "Updated:" "$file" | head -10 || true

    nl -ba "$file" | sed -n '1100,1140p'

  fi

  echo ""

done

echo "[status]"

git status --short

echo ""

echo "===== WINDOW COMPLETE ====="

git add PHASE719_INLINE_RECENT_TASKS_WINDOW.sh

git commit -m "Phase 719: inspect inline recent tasks source"

git push origin dev

