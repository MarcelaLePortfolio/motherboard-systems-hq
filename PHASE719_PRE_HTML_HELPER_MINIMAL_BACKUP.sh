
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PRE HTML HELPER MINIMAL BACKUP ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_PRE_HTML_HELPER_MINIMAL_BACKUP.txt"

{

  echo "PHASE 719 PRE HTML HELPER MINIMAL BACKUP"

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -8

  echo ""

  echo "Runtime health:"

  curl -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo ""

  echo "Backup reason:"

  echo "- Next patch touches worker artifact generation, route artifact selection, and frontend preview rendering."

  echo "- Current stable state preserves markdown artifact preview infrastructure."

  echo "- Failed direct HTML patch attempts were already reverted/sealed."

  echo "- This is the clean checkpoint before the minimal helper approach."

} | tee "$OUT"

if [ -x ./PHASE719_INCREMENTAL_BACKUP.sh ]; then

  ./PHASE719_INCREMENTAL_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

else

  echo "No incremental/external backup helper available."

fi

git add PHASE719_PRE_HTML_HELPER_MINIMAL_BACKUP.sh

git add "$OUT"

git commit -m "Phase 719: checkpoint before minimal HTML helper"

git push origin "$BRANCH"

echo "===== PRE HTML HELPER MINIMAL BACKUP COMPLETE ====="

