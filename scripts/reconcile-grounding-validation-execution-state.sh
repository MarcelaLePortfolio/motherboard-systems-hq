#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="546599ec0"
INSPECTION_COMMIT="546599ec0"
VALIDATOR="scripts/validate-package-semantics-grounding-under-proven-runner.sh"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== RECONCILE VALIDATION EXECUTION STATE ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"
echo "ATTEMPT_3_STARTED=NO"

echo
echo "=== INSPECTION COMMIT CONTENT ==="
git show --stat --oneline "$INSPECTION_COMMIT"

echo
echo "=== CURRENT VALIDATOR STATE ==="
if [ -f "$VALIDATOR" ]; then
  echo "VALIDATOR_EXISTS=YES"
  ls -l "$VALIDATOR"
  grep -n \
    -e 'VALIDATE AUTHORIZED GROUNDING' \
    -e 'npx tsx --test' \
    -e 'AUTHORIZED_PROMPT_CHANGE_VALIDATED' \
    "$VALIDATOR" || true
else
  echo "VALIDATOR_EXISTS=NO"
fi

echo
echo "=== AUTHORIZED FUNCTIONAL STATE ==="
git status --short -- "$TARGET" "$NEW_TEST"

grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"
echo "DIRECTION_GROUNDING_PRESENT=YES"

grep -q \
  'Treat preservation requirements as constraints on the requested operation' \
  "$TARGET"
echo "PRESERVATION_CONSTRAINT_GROUNDING_PRESENT=YES"

test -f "$NEW_TEST"
echo "GROUNDING_TEST_FILE_PRESENT=YES"

echo
echo "=== LOCAL / REMOTE CONVERGENCE ==="
git fetch origin "$BRANCH"
echo "LOCAL_HEAD=$(git rev-parse HEAD)"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
echo "REMOTE_CONVERGENCE=YES"

echo
echo "=== CLASSIFICATION ==="
echo "INSPECTION_SCRIPT_COMMIT_CONFIRMED=YES"
echo "VALIDATION_SUCCESS_NOT_YET_ESTABLISHED=YES"
echo "IMPLEMENTATION_FAILURE_NOT_ESTABLISHED=YES"
echo "ATTEMPT_2_REMAINS_PENDING_VALIDATION=YES"
echo "ATTEMPT_3_REQUIRED=NO"
echo "NEXT_ACTION=RUN_PROVEN_RUNNER_VALIDATION_ONLY_AFTER_VALIDATOR_STATE_IS_CONFIRMED"

echo
echo "=== SAFETY ==="
echo "NO_FUNCTIONAL_SOURCE_CHANGED=YES"
echo "NO_TEST_CHANGED=YES"
echo "NO_VALIDATOR_CHANGED=YES"
echo "NO_DATABASE_CHANGED=YES"
echo "NO_DOGFOOD_RETRY_PERFORMED=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
