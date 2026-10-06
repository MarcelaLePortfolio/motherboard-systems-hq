#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="60654e268"
VALIDATOR="scripts/validate-package-semantics-grounding-under-proven-runner.sh"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== VALIDATION NONEXECUTION INSPECTION ==="
echo "HEAD=$EXPECTED_HEAD"
echo "PREVIOUS_VALIDATION_RESULT=NOT_ESTABLISHED"
echo "ATTEMPT_3_STARTED=NO"
echo "FUNCTIONAL_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"

echo
echo "=== VALIDATOR FILE STATE ==="
if [ -f "$VALIDATOR" ]; then
  echo "VALIDATOR_EXISTS=YES"
  ls -l "$VALIDATOR"
  sed -n '1,260p' "$VALIDATOR"
else
  echo "VALIDATOR_EXISTS=NO"
fi

echo
echo "=== AUTHORIZED FUNCTIONAL WORKTREE STATE ==="
git status --short -- "$TARGET" "$NEW_TEST"
git diff -- "$TARGET" "$NEW_TEST"

echo
echo "=== GROUNDING MARKERS ==="
if grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"; then
  echo "DIRECTION_GROUNDING_PRESENT=YES"
else
  echo "DIRECTION_GROUNDING_PRESENT=NO"
fi

if grep -q \
  'Treat preservation requirements as constraints on the requested operation' \
  "$TARGET"; then
  echo "PRESERVATION_CONSTRAINT_GROUNDING_PRESENT=YES"
else
  echo "PRESERVATION_CONSTRAINT_GROUNDING_PRESENT=NO"
fi

if [ -f "$NEW_TEST" ]; then
  echo "GROUNDING_TEST_FILE_PRESENT=YES"
else
  echo "GROUNDING_TEST_FILE_PRESENT=NO"
fi

echo
echo "=== CURRENT HEAD / REMOTE ==="
echo "LOCAL_HEAD=$(git rev-parse HEAD)"
git fetch origin "$BRANCH"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo
echo "=== CLASSIFICATION ==="
echo "PREVIOUS_VALIDATION_EXECUTION_ESTABLISHED=NO"
echo "IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_2_STATUS=AWAITING_CORRECT_VALIDATION_EXECUTION"
echo "ATTEMPT_3_REQUIRED=NO"
echo "NEXT_BOUNDARY=IDENTIFY_VALIDATOR_NONEXECUTION_CAUSE"

echo
echo "=== SAFETY ==="
echo "TARGET_CODE_MUTATION_BY_THIS_INSPECTION=NONE"
echo "TEST_MUTATION_BY_THIS_INSPECTION=NONE"
echo "VALIDATOR_MUTATION_BY_THIS_INSPECTION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "DOGFOOD_RETRY=NO"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
