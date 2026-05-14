
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PRE RENDERED MODAL FETCH BACKUP ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

PROOF="checkpoints/PHASE719_PRE_RENDERED_MODAL_FETCH_BACKUP.txt"

{

  echo "PHASE 719 PRE RENDERED MODAL FETCH BACKUP"

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

  echo "Preview route sample:"

  TASK_ID="$(curl -s --max-time 10 http://localhost:3000/api/tasks?limit=10 | grep -o 't_[a-z0-9-]*' | head -n 1 || true)"

  if [ -n "${TASK_ID:-}" ]; then

    curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 60 || true

  else

    echo "No task id found."

  fi

  echo ""

  echo "Frontend preview modal markers:"

  grep -nE 'phase719-preview-modal|phase719OpenPreviewModal|artifact-preview|data-phase719-preview-artifact' public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "Next mutation:"

  echo "- Replace placeholder preview modal content with fetched rendered artifact content"

  echo "- Preserve read-only boundary"

  echo "- Preserve Details/Trace/Logs separation"

  echo "- No retry/execution contract changes"

  echo "- No DB schema mutations"

  echo "- No worker logic mutations"

} | tee "$PROOF"

if [ -x ./PHASE719_INCREMENTAL_BACKUP.sh ]; then

  ./PHASE719_INCREMENTAL_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

else

  echo "No incremental/external backup helper available."

fi

git add PHASE719_PRE_RENDERED_MODAL_FETCH_BACKUP.sh

git add "$PROOF"

git commit -m "Phase 719: checkpoint before rendered modal fetch"

git push origin "$BRANCH"

echo "===== PRE RENDERED MODAL FETCH BACKUP COMPLETE ====="

