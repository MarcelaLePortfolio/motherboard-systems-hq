
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: POST QUARANTINE STATUS CHECK ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_POST_QUARANTINE_STATUS_CHECK.txt"

{

  echo "PHASE 719 POST QUARANTINE STATUS CHECK"

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -10

  echo ""

  echo "Git status:"

  git status --short

  echo ""

  echo "Runtime health:"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "Artifact preview route sample:"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/t_3e163cb2-999d-4cdb-b618-baad85cff46c/artifact-preview' | head -n 80 || true

  echo ""

  echo "Quarantine folder sample:"

  find checkpoints/phase719_quarantined_failed_helpers -maxdepth 1 -type f | sort | head -n 40 || true

  echo ""

  echo "Current stable boundary:"

  echo "- Artifact infrastructure preserved."

  echo "- Failed helper scripts quarantined."

  echo "- Worker HTML artifact generation paused."

  echo "- Next artifact-contract work should be planned separately."

} | tee "$OUT"

git add PHASE719_POST_QUARANTINE_STATUS_CHECK.sh

git add "$OUT"

git commit -m "Phase 719: verify post-quarantine status"

git push origin "$BRANCH"

echo "===== POST QUARANTINE STATUS CHECK COMPLETE ====="

