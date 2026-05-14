
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REVERT PARTIAL HTML ARTIFACT ATTEMPT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_REVERT_PARTIAL_HTML_ARTIFACT_ATTEMPT.txt"

{

  echo "PHASE 719 REVERT PARTIAL HTML ARTIFACT ATTEMPT"

  echo ""

  echo "Reason:"

  echo "- HTML artifact direct-render patch hypothesis has failed 3 times on exact worker emit/payload matching."

  echo "- Last attempt may have left partial uncommitted edits."

  echo "- Per build protocol, revert targeted files to last committed stable state before trying a cleaner approach."

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD before revert:"

  git log --oneline --decorate -8

  echo ""

  echo "Status before revert:"

  git status --short

  echo ""

  echo "Diff before revert:"

  git diff -- server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs public/js/phase530_visible_panels_bridge.js || true

} | tee "$OUT"

git checkout -- server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs public/js/phase530_visible_panels_bridge.js

{

  echo ""

  echo "Status after targeted revert:"

  git status --short

  echo ""

  echo "Syntax after targeted revert:"

  node --check server/worker/phase26_task_worker.mjs || true

  node --check server/routes/api-tasks-postgres.mjs || true

  node --check public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "Runtime health:"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "Stable boundary:"

  echo "- Preserve existing artifact infrastructure."

  echo "- Do not continue exact-string HTML artifact patching."

  echo "- Next approach should use a smaller isolated worker helper or append-only route-safe implementation."

} >> "$OUT"

git add PHASE719_REVERT_PARTIAL_HTML_ARTIFACT_ATTEMPT.sh

git add "$OUT"

git commit -m "Phase 719: revert partial HTML artifact attempt"

git push origin "$BRANCH"

echo "===== PARTIAL HTML ARTIFACT ATTEMPT REVERT COMPLETE ====="

