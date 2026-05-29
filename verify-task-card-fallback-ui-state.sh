
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_CARD_FALLBACK_UI_STATE_VERIFY.txt"

{

  echo "===== TASK CARD FALLBACK UI STATE VERIFY ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== VERIFY RENDERER FALLBACKS PRESENT ====="

  grep -nE "payload && t.payload.artifact|status: \\$\\{status\\}|payload && t.payload.trace|payload && t.payload.meta" public/js/phase530_visible_panels_bridge.js || true

  echo

  echo "===== VERIFY /api/tasks ====="

  curl -sS "http://localhost:8080/api/tasks?limit=5" | python3 -m json.tool

  echo

  echo "===== VERIFY HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== GIT STATUS ====="

  git status --short

} | tee "$REPORT"

git add verify-task-card-fallback-ui-state.sh "$REPORT"

git commit -m "Verify task card fallback UI state"

git push

open "http://localhost:8080/?v=task-card-fallbacks-663d043c"

