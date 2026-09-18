#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT HEAD ===\n'
git rev-parse HEAD

printf '\n=== TEST DIFF PRESENT ===\n'
git status --short -- "$TEST"
git diff --check -- "$TEST"

printf '\n=== RUN ONLY THE AUTHORIZED LIFECYCLE TEST ===\n'
TEST_STATUS=0
node --test --import tsx "$TEST" || TEST_STATUS=$?

printf '\n=== RESULT ===\n'
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

if [ "$TEST_STATUS" -eq 0 ]; then
  echo "LIFECYCLE_TEST_RESULT=PASS"
  echo "NEW_IMPLEMENTATION_HYPOTHESIS_FAILURE_COUNT=0"
  echo "NEXT_ACTION=RUN_REMAINING_REGRESSION_VALIDATION"
else
  echo "LIFECYCLE_TEST_RESULT=FAIL"
  echo "NEW_IMPLEMENTATION_HYPOTHESIS_FAILURE_COUNT=1"
  echo "NEXT_ACTION=DIAGNOSE_THIS_EXACT_FAILURE_ONLY"
fi

echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
