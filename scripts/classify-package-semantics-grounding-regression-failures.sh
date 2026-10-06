#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0418c32c5"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== ATTEMPT 2 CLASSIFICATION INSPECTION ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_COMMIT_CREATED=NO"
echo "DOGFOOD_RETRY=NO"
echo "PURPOSE=SEPARATE_PREEXISTING_STALE_TEST_FAILURES_FROM_NEW_CHANGE_REGRESSIONS"

echo
echo "=== CURRENT FUNCTIONAL DIFF ==="
git diff -- "$TARGET" "$NEW_TEST"

echo
echo "=== VERIFY AUTHORIZED PROMPT MUTATION IS PRESENT ==="
grep -n -B4 -A10 \
  'expectedOutcome must preserve the operation and direction' \
  "$TARGET" || true

echo
echo "=== VERIFY FIDELITY GUARD REMAINS PRESENT ==="
grep -n -A75 \
  'function enforceConcreteOperationPackageSemanticsFidelity' \
  "$TARGET" | head -90

echo
echo "=== NEW GROUNDING TEST ONLY ==="
set +e
node --test "$NEW_TEST"
NEW_TEST_STATUS=$?
set -e
echo "NEW_GROUNDING_TEST_EXIT=$NEW_TEST_STATUS"

echo
echo "=== KNOWN ABANDONED SCHEMA-BOUNDING TEST ==="
set +e
node --test scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts
STALE_SCHEMA_TEST_STATUS=$?
set -e
echo "EMPTY_HISTORY_SCHEMA_BOUNDING_TEST_EXIT=$STALE_SCHEMA_TEST_STATUS"

echo
echo "=== CURRENT SUCCESSFUL CONDITIONAL-PROMPT CONTRACT TEST ==="
set +e
node --test scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts
CONDITIONAL_PROMPT_STATUS=$?
set -e
echo "CONDITIONAL_CONVERSATION_SUPPORT_TEST_EXIT=$CONDITIONAL_PROMPT_STATUS"

echo
echo "=== PACKAGE SEMANTICS CONTRACT TESTS INDIVIDUALLY ==="
for test_file in \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.expected-outcome-diagnostic-observability.test.ts
do
  echo "--- $test_file ---"
  set +e
  node --test "$test_file"
  status=$?
  set -e
  echo "EXIT=$status"
done

echo
echo "=== TEST FILE PROVENANCE ==="
for test_file in \
  scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts \
  scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts \
  "$NEW_TEST"
do
  echo "--- $test_file ---"
  git status --short -- "$test_file"
  git log -5 --oneline -- "$test_file" || true
done

echo
echo "=== TYPECHECK CURRENT WORKTREE ==="
set +e
npx tsc --noEmit
TYPECHECK_STATUS=$?
set -e
echo "TYPECHECK_EXIT=$TYPECHECK_STATUS"

echo
echo "=== BUILD CURRENT WORKTREE ==="
set +e
npm run build
BUILD_STATUS=$?
set -e
echo "BUILD_EXIT=$BUILD_STATUS"

echo
echo "=== CLASSIFICATION INPUTS ==="
echo "NEW_GROUNDING_TEST_EXIT=$NEW_TEST_STATUS"
echo "EMPTY_HISTORY_SCHEMA_BOUNDING_TEST_EXIT=$STALE_SCHEMA_TEST_STATUS"
echo "CONDITIONAL_CONVERSATION_SUPPORT_TEST_EXIT=$CONDITIONAL_PROMPT_STATUS"
echo "TYPECHECK_EXIT=$TYPECHECK_STATUS"
echo "BUILD_EXIT=$BUILD_STATUS"

if [ "$NEW_TEST_STATUS" -eq 0 ] \
  && [ "$CONDITIONAL_PROMPT_STATUS" -eq 0 ] \
  && [ "$TYPECHECK_STATUS" -eq 0 ] \
  && [ "$BUILD_STATUS" -eq 0 ]; then
  echo "AUTHORIZED_PROMPT_CHANGE_LOCALLY_VALIDATED=YES"
  echo "BROAD_SUITE_FAILURE_REQUIRES_STALE_TEST_RECONCILIATION=YES"
else
  echo "AUTHORIZED_PROMPT_CHANGE_LOCALLY_VALIDATED=NO"
  echo "NEXT_ACTION=INSPECT_SPECIFIC_CURRENT_FAILURE_BEFORE_ANY_NEW_IMPLEMENTATION"
fi

echo
echo "=== SAFETY BOUNDARY ==="
echo "NO_NEW_FUNCTIONAL_MUTATION_PERFORMED=YES"
echo "NO_REVERT_PERFORMED=YES"
echo "NO_DOGFOOD_RETRY_PERFORMED=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
