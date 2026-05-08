
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 DIRECT INSPECT TARGET FILES ====="

echo ""

echo "[1] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Inspect known renderer bridge"

sed -n '1,260p' public/js/phase530_visible_panels_bridge.js

echo ""

echo "[3] Inspect known task routes"

sed -n '1,220p' routes/api/tasks.ts

echo ""

sed -n '1,220p' routes/tasks.ts

echo ""

echo "[4] Inspect known prior retry notes"

for file in \

  PHASE571_RETRY_DIFFERENTLY_BUTTON_VERIFIED.txt \

  PHASE582_RETRY_ACTIONS_WIRED_STABLE.txt \

  PHASE583_WORKER_RETRY_VISIBILITY_ACTIVE.txt \

  PHASE583_ENFORCE_RETRY_CONTRACT_INTEGRATION.txt \

  PHASE674_RETRY_CONTRACT_DISCOVERY.md

do

  if [ -f "$file" ]; then

    echo ""

    echo "----- $file -----"

    sed -n '1,160p' "$file"

  fi

done

echo ""

echo "===== PHASE 717 DIRECT INSPECT TARGET FILES COMPLETE ====="

