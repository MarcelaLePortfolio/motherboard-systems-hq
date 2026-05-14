
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT PHASE530 TASKROWS EXACT ====="

mkdir -p checkpoints

{

  echo "TASKROWS FUNCTION EXCERPT"

  nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '70,190p'

  echo ""

  echo "ARTIFACT PATCH STATUS"

  grep -nE "artifact|artifacts|outcome_preview|explanation_preview|phase717-muted|taskRows" public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "RUNTIME HEALTH"

  curl -s http://localhost:3000/api/tasks/health || true

} | tee checkpoints/PHASE719_PHASE530_TASKROWS_EXACT_INSPECTION.txt

git add PHASE719_INSPECT_PHASE530_TASKROWS_EXACT.sh checkpoints/PHASE719_PHASE530_TASKROWS_EXACT_INSPECTION.txt

git commit -m "Phase 719: inspect exact recent tasks renderer"

git push origin "$(git branch --show-current)"

