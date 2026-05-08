
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 715 GIT PUSH RECOVERY ====="

echo ""

echo "[1] Current branch / remote state"

git branch --show-current

git status --short

git log --oneline --decorate -8

echo ""

echo "[2] Confirm commits ahead of origin/dev"

git fetch origin dev --tags

git log --oneline --decorate origin/dev..HEAD || true

echo ""

echo "[3] Inspect largest objects only in commits ahead of origin/dev"

git rev-list --objects origin/dev..HEAD \

  | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \

  | awk '$1=="blob" {print $3, $4}' \

  | sort -nr \

  | head -40 \

  | awk '{size=$1; $1=""; printf "%.2f MB%s\n", size/1024/1024, $0}' || true

echo ""

echo "[4] Push branch only — DO NOT push all tags"

git push origin dev

echo ""

echo "[5] Push only the intended Phase 715 tag if it exists locally"

if git rev-parse "phase715-pre-execution-evidence-ui" >/dev/null 2>&1; then

  git push origin "phase715-pre-execution-evidence-ui"

else

  echo "No local phase715-pre-execution-evidence-ui tag found."

fi

echo ""

echo "[6] Verify remote branch and tag"

git ls-remote --heads origin dev

git ls-remote --tags origin | grep "phase715-pre-execution-evidence-ui" || true

echo ""

echo "[7] Final status"

git status --short

echo "===== PHASE 715 GIT PUSH RECOVERY COMPLETE ====="

