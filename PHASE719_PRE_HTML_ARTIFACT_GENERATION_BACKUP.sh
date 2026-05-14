
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PRE HTML ARTIFACT GENERATION BACKUP ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_PRE_HTML_ARTIFACT_GENERATION_BACKUP.txt"

{

  echo "PHASE 719 PRE HTML ARTIFACT GENERATION BACKUP"

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

  echo "Current state:"

  echo "- Artifact persistence works"

  echo "- Shared worker/dashboard artifact volume works"

  echo "- Read-only artifact-preview route works"

  echo "- Preview modal fetches artifact content"

  echo "- Current visual card is generated frontend HTML from markdown, not artifact-authored HTML"

  echo ""

  echo "Next mutation:"

  echo "- Add worker-produced HTML artifact alongside markdown"

  echo "- Update artifact metadata so Preview prefers HTML artifact"

  echo "- Preserve markdown artifact as fallback"

  echo "- Preserve read-only route"

  echo "- Preserve retry/execution contract"

  echo "- No DB schema changes"

  echo ""

  echo "Markers:"

  grep -nE 'persistTaskArtifact|artifactPath|writeFileSync|artifacts|artifact-preview|phase719RenderArtifactVisualCard' server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs public/js/phase530_visible_panels_bridge.js || true

} | tee "$OUT"

if [ -x ./PHASE719_INCREMENTAL_BACKUP.sh ]; then

  ./PHASE719_INCREMENTAL_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

else

  echo "No incremental/external backup helper available."

fi

git add PHASE719_PRE_HTML_ARTIFACT_GENERATION_BACKUP.sh

git add "$OUT"

git commit -m "Phase 719: checkpoint before HTML artifact generation"

git push origin "$BRANCH"

echo "===== PRE HTML ARTIFACT GENERATION BACKUP COMPLETE ====="

