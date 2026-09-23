#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="131be69e4"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== THREE-ATTEMPT PROTOCOL TRIGGERED ===\n'
echo "FAILED_IMPLEMENTATION_ATTEMPTS=3"
echo "CURRENT_HYPOTHESIS=SERVER_SIDE_VALIDATION_ELIGIBILITY_GATE"
echo "ACTION=RESET_AND_CHANGE_HYPOTHESIS"
echo "RUNTIME_REPAIR_COMMITTED=NO"
echo "RUNTIME_REPAIR_PUSHED=NO"

printf '\n=== ATTEMPT 3 DIAGNOSTIC CLASSIFICATION ===\n'
echo "TYPECHECK_RESULT=PASSED"
echo "TARGETED_TEST_INVOCATION_RESULT=FAILED"
echo "FAILURE_CLASS=TEST_RUNNER_MODULE_RESOLUTION"
echo "FAILURE_SIGNATURE=ERR_MODULE_NOT_FOUND_ON_EXTENSIONLESS_TYPESCRIPT_IMPORTS"
echo "RUNTIME_DEFECT_PROVEN_BY_ATTEMPT_3=NO"
echo "IMPLEMENTATION_CORRECTNESS_PROVEN=NO"

printf '\n=== VERIFY RUNTIME FILES ARE BACK AT STABLE HEAD ===\n'
git diff --exit-code -- \
  server/validation/production-validation-consumer.ts \
  server/validation/production-validation-consumer.test.ts

printf '\n=== INSPECT PROJECT TEST RUNNER CONTRACT ===\n'
cat package.json

printf '\n=== SEARCH EXISTING TEST COMMANDS / TS RUNNERS ===\n'
grep -Rni -E \
  'tsx|ts-node|node --test|--loader|--import|test:|npm run test|npx tsx' \
  package.json \
  client/package.json \
  scripts \
  server \
  .github \
  2>/dev/null | head -700 || true

printf '\n=== SEARCH PRIOR SUCCESSFUL VALIDATION TEST INVOCATIONS ===\n'
git log --all --oneline -- \
  server/validation/production-validation-consumer.test.ts \
  server/validation/production-validation-entry-point.test.ts \
  server/routes/governance-validation-route.test.ts | head -80

printf '\n=== NEW HYPOTHESIS ===\n'
echo "HYPOTHESIS_2=THE_AUTHORIZED_RUNTIME_REPAIR_MAY_BE_VALID_BUT_TESTS_MUST_USE_THE_REPOSITORY_CONFIGURED_TYPESCRIPT_RUNNER"
echo "IMPLEMENTATION_ATTEMPTS_UNDER_NEW_HYPOTHESIS=0"
echo "NEXT_ACTION=PROVE_EXACT_TEST_RUNNER_BEFORE_ANY_NEW_RUNTIME_EDIT"
echo "NO_IMPLEMENTATION_EDIT_IN_THIS_STEP=YES"
echo "NO_LIVE_GOVERNANCE_DATA_MUTATION=YES"
echo "NO_UI_CHANGE=YES"
echo "NO_NEW_AUTHORITY=YES"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_ELIGIBILITY_THREE_ATTEMPT_RESET=COMPLETE\n'
