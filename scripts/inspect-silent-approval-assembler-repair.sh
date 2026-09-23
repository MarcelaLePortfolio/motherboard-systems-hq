#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

echo "===== HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== RECENT COMMITS ====="
git log -6 --oneline --decorate

echo
echo "===== AUTHORIZED TARGET STATUS ====="
git status --short -- \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts \
  db/approval-request-model-assembler.ts \
  scripts/implement-success-criteria-draft-revision-summary.sh \
  scripts/repair-success-criteria-approval-assembler-boundary.sh

echo
echo "===== AUTHORIZED TARGET DIFF ====="
git diff -- \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts \
  db/approval-request-model-assembler.ts \
  scripts/implement-success-criteria-draft-revision-summary.sh \
  scripts/repair-success-criteria-approval-assembler-boundary.sh

echo
echo "===== APPROVAL ASSEMBLER EXACT BOUNDARY ====="
grep -n -B 30 -A 50 \
  -E 'assembleReconciledInterpretationSummary|expected_outcome|success_criteria' \
  db/approval-request-model-assembler.ts || true

echo
echo "===== DRAFT REVISION / RECONCILED SUMMARY STATE ====="
grep -n -B 15 -A 30 \
  -E 'success_criteria|expected_outcome|unresolved_questions' \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts || true

echo
echo "===== TYPECHECK STATUS ====="
npx tsc --noEmit || true

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
