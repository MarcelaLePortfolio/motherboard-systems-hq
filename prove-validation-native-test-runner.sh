#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="bb2ba69d3"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== NEW HYPOTHESIS — RUNNER PROOF ONLY ===\n'
echo "HYPOTHESIS=AUTHORIZED_REPAIR_MAY_BE_VALID_BUT_MUST_BE_VALIDATED_WITH_REPOSITORY_NATIVE_TSX"
echo "IMPLEMENTATION_ATTEMPTS_UNDER_NEW_HYPOTHESIS=0"
echo "RUNTIME_EDIT=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== VERIFY STABLE RUNTIME ===\n'
git diff --exit-code -- \
  server/validation/production-validation-consumer.ts \
  server/validation/production-validation-consumer.test.ts

printf '\n=== VERIFY REPOSITORY-NATIVE TSX ===\n'
test -x ./node_modules/.bin/tsx
./node_modules/.bin/tsx --version

printf '\n=== STABLE BASE TYPECHECK ===\n'
npm run check

printf '\n=== STABLE BASE TARGETED VALIDATION TESTS VIA TSX ===\n'
./node_modules/.bin/tsx --test \
  server/routes/governance-validation-route.test.ts \
  server/validation/production-validation-consumer.test.ts \
  server/validation/production-validation-entry-point.test.ts

printf '\n=== RUNNER PROOF RESULT ===\n'
echo "REPOSITORY_NATIVE_TSX_RUNNER=PROVEN"
echo "STABLE_VALIDATION_TESTS=PASS"
echo "PREVIOUS_RAW_NODE_FAILURE=RUNNER_RESOLUTION_FAILURE"
echo "RUNTIME_DEFECT_PROVEN_BY_PREVIOUS_FAILURE=NO"
echo "NEXT_ACTION=REASSESS_AUTHORIZED_REPAIR_UNDER_NEW_HYPOTHESIS"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "NEW_AUTHORITY=NO"

printf '\nVALIDATION_NATIVE_TEST_RUNNER_PROOF=COMPLETE\n'
