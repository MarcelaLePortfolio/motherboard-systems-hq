
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT WORKER ARTIFACT FUNCTION EXACT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

WORKER="server/worker/phase26_task_worker.mjs"

OUT="checkpoints/PHASE719_WORKER_ARTIFACT_FUNCTION_EXACT_INSPECTION.txt"

{

  echo "BRANCH"

  echo "$BRANCH"

  echo ""

  echo "HEAD"

  git log --oneline --decorate -8

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "WORKER ARTIFACT FUNCTION LINES 110-235"

  nl -ba "$WORKER" | sed -n '110,235p'

  echo ""

  echo "WORKER ARTIFACT MARKERS"

  grep -nE 'persistTaskArtifact|artifactDir|artifactPath|filename|writeFileSync|stat|return|artifact|artifacts|task.completed' "$WORKER" || true

  echo ""

  echo "ROUTE ARTIFACT SELECTION LINES 145-190"

  nl -ba server/routes/api-tasks-postgres.mjs | sed -n '145,190p'

  echo ""

  echo "FRONTEND HTML MARKERS"

  grep -nE 'phase719RenderHtmlArtifactPreview|render_mode|phase719RenderArtifactVisualCard|phase719RenderMarkdownArtifactPreview' public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "SYNTAX"

  node --check "$WORKER" || true

  node --check server/routes/api-tasks-postgres.mjs || true

  node --check public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

} | tee "$OUT"

git add PHASE719_INSPECT_WORKER_ARTIFACT_FUNCTION_EXACT.sh

git add PHASE719_ADD_HTML_ARTIFACT_AND_RENDER_DIRECTLY.sh || true

git add "$OUT"

git commit -m "Phase 719: inspect exact worker artifact function before HTML generation"

git push origin "$BRANCH"

echo "===== WORKER ARTIFACT FUNCTION INSPECTION COMPLETE ====="

