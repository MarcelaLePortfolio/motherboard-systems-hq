
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PRE PREVIEW PILL CHECKPOINT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

HEAD_SHA="$(git rev-parse --short HEAD)"

{

  echo "PHASE 719 PREVIEW PILL CHECKPOINT"

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

  echo "Artifact UI marker:"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "Artifact:" | head || true

  echo ""

  echo "Preview corridor target:"

  echo "- Replace lifecycle pill semantics with preview semantics"

  echo "- Preserve frontend-only boundary"

  echo "- Preserve retry contract"

  echo "- Preserve artifact metadata line"

  echo "- No backend routing mutations"

  echo "- No execution coupling"

  echo ""

  echo "Git status:"

  git status --short

} | tee checkpoints/PHASE719_PRE_PREVIEW_PILL_CHECKPOINT.txt

if [ -x ./PHASE719_INCREMENTAL_BACKUP.sh ]; then

  ./PHASE719_INCREMENTAL_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

else

  echo "No incremental/external backup helper available."

fi

git add PHASE719_PRE_PREVIEW_PILL_CHECKPOINT.sh \

  checkpoints/PHASE719_PRE_PREVIEW_PILL_CHECKPOINT.txt

git commit -m "Phase 719: checkpoint before preview pill corridor"

git push origin "$BRANCH"

echo "===== PREVIEW PILL CHECKPOINT SEALED ====="

