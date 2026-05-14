
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PRE RENDERED ARTIFACT PREVIEW BACKUP ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

PROOF="checkpoints/PHASE719_PRE_RENDERED_ARTIFACT_PREVIEW_BACKUP.txt"

{

  echo "PHASE 719 PRE RENDERED ARTIFACT PREVIEW BACKUP"

  echo ""

  echo "Timestamp:"

  date

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -5

  echo ""

  echo "Runtime health:"

  curl -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "Preview modal markers:"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "phase719-preview-modal|phase719OpenPreviewModal|data-phase719-preview-artifact" | head -n 20 || true

  echo ""

  echo "Next mutation:"

  echo "- Convert Preview modal from metadata/details surface into rendered artifact surface"

  echo "- Prefer rendered markdown/text artifact content"

  echo "- Preserve frontend-only boundary"

  echo "- No backend routing changes"

  echo "- No retry/execution contract changes"

  echo "- Preserve Details/Trace/Logs separation"

} | tee "$PROOF"

if [ -x ./PHASE719_INCREMENTAL_BACKUP.sh ]; then

  ./PHASE719_INCREMENTAL_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

else

  echo "No incremental/external backup helper available."

fi

git add PHASE719_PRE_RENDERED_ARTIFACT_PREVIEW_BACKUP.sh

git add "$PROOF"

git commit -m "Phase 719: checkpoint before rendered artifact preview"

git push origin "$BRANCH"

echo "===== RENDERED ARTIFACT PREVIEW BACKUP COMPLETE ====="

