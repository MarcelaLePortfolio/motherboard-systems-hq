
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PRE PREVIEW MODAL BACKUP ====="

BRANCH="$(git branch --show-current)"

PROOF="checkpoints/PHASE719_PRE_PREVIEW_MODAL_BACKUP_PROOF.txt"

mkdir -p checkpoints

{

  echo "PHASE 719 PRE PREVIEW MODAL BACKUP"

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

  echo ""

  echo "Preview marker:"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "data-phase719-preview-artifact|Preview|lifecycle" | head || true

  echo ""

  echo "Next mutation:"

  echo "- Add read-only Preview modal behavior"

  echo "- Frontend-only"

  echo "- No backend routes"

  echo "- No retry/execution changes"

} | tee "$PROOF"

if [ -x ./PHASE719_INCREMENTAL_BACKUP.sh ]; then

  ./PHASE719_INCREMENTAL_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

fi

git add PHASE719_PRE_PREVIEW_MODAL_BACKUP.sh "$PROOF"

git commit -m "Phase 719: checkpoint before preview modal"

git push origin "$BRANCH"

echo "===== PREVIEW MODAL BACKUP COMPLETE ====="

