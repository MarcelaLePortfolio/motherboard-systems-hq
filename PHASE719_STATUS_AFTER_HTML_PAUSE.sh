
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: STATUS AFTER HTML PAUSE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_STATUS_AFTER_HTML_PAUSE.txt"

{

  echo "PHASE 719 STATUS AFTER HTML PAUSE"

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -10

  echo ""

  echo "Runtime health:"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "Current artifact corridor:"

  echo "- Backend/runtime healthy."

  echo "- Preview pill and modal exist."

  echo "- Shared artifact volume exists."

  echo "- Read-only artifact-preview route works."

  echo "- Frontend visual card renderer exists."

  echo "- Worker HTML artifact generation is paused."

  echo ""

  echo "Untracked Phase 719 helper/dead-end files:"

  git status --short | grep -E '^\?\? PHASE719_|^\?\? checkpoints/PHASE719_' || true

  echo ""

  echo "Recommended next step:"

  echo "- Either create handoff now, or clean/quarantine failed helper scripts before continuing."

  echo "- Do not retry worker HTML artifact mutation without a proper artifact contract refactor."

} | tee "$OUT"

git add PHASE719_STATUS_AFTER_HTML_PAUSE.sh

git add "$OUT"

git commit -m "Phase 719: record status after HTML pause"

git push origin "$BRANCH"

echo "===== STATUS AFTER HTML PAUSE COMPLETE ====="

