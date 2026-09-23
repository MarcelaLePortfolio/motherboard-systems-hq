#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="0e51f2479"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== DRAFT REVISION RUNTIME ====="
cat db/matilda-draft-revision-runtime.ts

echo
echo "===== DRAFT REVISION TEST / FIXTURE SURFACES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'DraftRevisionRecord|matilda_draft_revisions|expected_outcome|success_criteria|unresolved_questions|createDraftRevisionForApprovalReview' \
  db server scripts 2>/dev/null | head -500

echo
echo "===== LIVING DRAFT SOURCE CONTRACT ====="
grep -n -B 20 -A 80 \
  -E 'success_criteria|expected_outcome|LivingDraftPackage' \
  db/matilda-living-draft-runtime.ts \
  db/matilda-living-draft-read-runtime.ts

echo
echo "===== RECONCILED CONSUMER BOUNDARY ====="
grep -n -B 15 -A 40 \
  -E 'ReconciledIntentSummary|expected_outcome|success_criteria|unresolved_questions' \
  db/matilda-reconciled-intent-runtime.ts

echo
echo "===== CURRENT HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
