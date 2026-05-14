
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REVERT FAILED HTML HELPER MINIMAL ATTEMPT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_REVERT_FAILED_HTML_HELPER_MINIMAL_ATTEMPT.txt"

{

  echo "PHASE 719 REVERT FAILED HTML HELPER MINIMAL ATTEMPT"

  echo ""

  echo "Reason:"

  echo "- Minimal helper attempt failed on artifacts payload line."

  echo "- Script may have partially edited worker/route/frontend before refusing."

  echo "- Reverting targeted files to committed checkpoint d29d13d7 boundary before next approach."

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

  echo "Targeted diff before revert:"

  git diff -- server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "Worker emit block before revert:"

  nl -ba server/worker/phase26_task_worker.mjs | sed -n '190,230p'

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

  echo "Next rule:"

  echo "- Do not retry worker HTML mutation by exact-string patch again."

  echo "- Use an isolated inspection-first approach or defer HTML generation corridor."

} >> "$OUT"

git add PHASE719_REVERT_FAILED_HTML_HELPER_MINIMAL_ATTEMPT.sh

git add "$OUT"

git commit -m "Phase 719: revert failed minimal HTML helper attempt"

git push origin "$BRANCH"

echo "===== FAILED HTML HELPER MINIMAL ATTEMPT REVERT COMPLETE ====="

