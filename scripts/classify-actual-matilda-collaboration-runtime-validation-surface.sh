#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY ACTUAL MATILDA COLLABORATION RUNTIME VALIDATION SURFACE ==="

REQUIRED_ANCESTOR="19898c3c"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: validation-test inspection checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-actual-matilda-collaboration-runtime-validation-surface\.sh$|^ M scripts/classify-actual-matilda-collaboration-runtime-validation-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY INSPECTION SIGNAL ==="
grep -nE \
  'VALIDATION_TEST_FILENAME_INSPECTION_COMPLETE|PRODUCTION_RUNTIME_CHANGE=NONE|VALIDATION_SCRIPT_CHANGE=NONE|NEXT_ACTION=CLASSIFY_ACTUAL_MILESTONE_VALIDATION_TEST_SET' \
  scripts/inspect-matilda-collaboration-runtime-validation-tests.sh

echo
echo "=== VERIFY ACTUAL LIFECYCLE TEST INVENTORY ==="
find scripts/utils db server -type f \
  \( -name '*investigation*lifecycle*test.ts' -o -name '*ollamaChat*test.ts' \) \
  -print |
sort

echo
echo "=== VERIFY INVESTIGATION LIFECYCLE CONTRACT TEST EXISTS ==="
test -f scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts || {
  echo "STOP: required Investigation Lifecycle contract test is missing."
  exit 2
}
echo "INVESTIGATION_LIFECYCLE_CONTRACT_TEST_PRESENT"

echo
echo "=== VERIFY PRIOR CONTEXT COVERAGE IS INSIDE CONTRACT TEST ==="
grep -nE \
  'priorInvestigationLifecycle|continued preserves prior investigation identity|advanced preserves prior investigation identity|cross-turn validator is invoked after structured response parsing' \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts
echo "PRIOR_CONTEXT_AND_CONTINUITY_COVERAGE_CONFIRMED_IN_CONTRACT_TEST"

echo
echo "=== VERIFY NO SEPARATE PRIOR-LIFECYCLE TEST FILE EXISTS ==="
separate_prior_test="$(
  find scripts/utils db server -type f \
    -name '*prior*investigation*lifecycle*test.ts' \
    -print |
  head -n 1
)"

if [[ -n "$separate_prior_test" ]]; then
  echo "STOP: a separate prior-lifecycle test exists and must be evaluated:"
  printf '%s\n' "$separate_prior_test"
  exit 2
fi
echo "SEPARATE_PRIOR_LIFECYCLE_TEST_FILE=ABSENT"

echo
echo "=== VERIFY NO SEPARATE DB / WORKFLOW LIFECYCLE TEST FILES ==="
separate_runtime_tests="$(
  find db server -type f \
    \( -name '*investigation*lifecycle*test.ts' -o -name '*lifecycle*retrieval*test.ts' -o -name '*lifecycle*transport*test.ts' \) \
    -print
)"

if [[ -n "$separate_runtime_tests" ]]; then
  echo "STOP: separate DB/workflow lifecycle tests exist and must be classified explicitly:"
  printf '%s\n' "$separate_runtime_tests"
  exit 2
fi
echo "SEPARATE_DB_WORKFLOW_LIFECYCLE_TEST_FILES=ABSENT"

echo
echo "=== VERIFY IMPLEMENTATION SURFACES DIRECTLY ==="
grep -nE \
  'priorInvestigationLifecycle|validateMatildaInvestigationLifecycleArtifact|validateMatildaInvestigationLifecycleContinuity|investigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 260

grep -nE \
  'investigation_lifecycle_json|investigationLifecycle|projectId|conversationId|ORDER BY|LIMIT' \
  db/matilda-interpretation-runtime.ts |
head -n 320

grep -nE \
  'listInterpretationEvidenceLedgerEntries|priorInvestigationLifecycle|investigationLifecycle|insertInterpretationEvidenceLedgerEntry|createMatildaConversationTurn|await ollamaChat\(' \
  server/matilda-chat-workflow.ts |
head -n 360

echo
echo "ACTUAL_MILESTONE_VALIDATION_SURFACE_CLASSIFIED"
echo "TYPESCRIPT_TEST_RUNNER=TSX"
echo "INVESTIGATION_LIFECYCLE_CONTRACT_TEST=AUTHORITATIVE_PRESENT_TEST"
echo "PRIOR_CONTEXT_COVERAGE=INSIDE_INVESTIGATION_LIFECYCLE_CONTRACT_TEST"
echo "SEPARATE_PRIOR_LIFECYCLE_TEST=ABSENT"
echo "SEPARATE_DB_WORKFLOW_LIFECYCLE_TESTS=ABSENT"
echo "DIRECT_REPOSITORY_ASSERTIONS_REQUIRED=YES"
echo "SHELL_PORTABILITY=MACOS_BASH_COMPATIBLE"
echo "PRODUCTION_RUNTIME_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=RERUN_MILESTONE_CLOSURE_VALIDATION_WITH_ACTUAL_REPOSITORY_SURFACE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts
then
  echo "STOP: production runtime changed during validation-surface classification."
  exit 2
fi
echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-actual-matilda-collaboration-runtime-validation-surface\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside validation-surface classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi
echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-actual-matilda-collaboration-runtime-validation-surface.sh
git diff --cached --check
git commit -m "Classify actual milestone validation surface"
git push
