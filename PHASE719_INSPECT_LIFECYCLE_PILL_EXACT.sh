
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT LIFECYCLE PILL EXACT ====="

mkdir -p checkpoints

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "LIFECYCLE / PREVIEW / HEADER MARKERS"

  grep -nE "lifecycle|Preview|phase719-preview|artifactRaw|data-phase717-execution-card|strategy:|retry of:" public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "HEADER BLOCK LINES 178-215"

  nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '178,215p'

  echo ""

  echo "SYNTAX"

  node --check public/js/phase530_visible_panels_bridge.js || true

} | tee checkpoints/PHASE719_LIFECYCLE_PILL_EXACT_INSPECTION.txt

git add PHASE719_REPLACE_LIFECYCLE_WITH_CONDITIONAL_PREVIEW.sh

git add PHASE719_INSPECT_LIFECYCLE_PILL_EXACT.sh

git add checkpoints/PHASE719_LIFECYCLE_PILL_EXACT_INSPECTION.txt

git add checkpoints/PHASE719_PHASE530_PRE_CONDITIONAL_PREVIEW.js || true

git commit -m "Phase 719: inspect exact lifecycle pill before preview replacement"

git push origin "$(git branch --show-current)"

echo "===== LIFECYCLE INSPECTION COMPLETE ====="

