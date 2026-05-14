
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT PARTIAL HTML ARTIFACT PATCH STATE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_PARTIAL_HTML_ARTIFACT_PATCH_STATE.txt"

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

  echo "WORKER DIFF"

  git diff -- server/worker/phase26_task_worker.mjs || true

  echo ""

  echo "ROUTE DIFF"

  git diff -- server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "FRONTEND DIFF"

  git diff -- public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "WORKER LINES 110-235"

  nl -ba server/worker/phase26_task_worker.mjs | sed -n '110,235p'

  echo ""

  echo "WORKER EMIT BLOCK LINES 200-230"

  nl -ba server/worker/phase26_task_worker.mjs | sed -n '200,230p'

  echo ""

  echo "SYNTAX"

  node --check server/worker/phase26_task_worker.mjs || true

  node --check server/routes/api-tasks-postgres.mjs || true

  node --check public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

} | tee "$OUT"

git add PHASE719_INSPECT_PARTIAL_HTML_ARTIFACT_PATCH_STATE.sh

git add "$OUT"

git commit -m "Phase 719: inspect partial HTML artifact patch state"

git push origin "$BRANCH"

echo "===== PARTIAL HTML ARTIFACT PATCH STATE INSPECTION COMPLETE ====="

