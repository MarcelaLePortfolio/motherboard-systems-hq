#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ccbb69edd"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== RECOVERY CLASSIFICATION ===\n'
echo "FAILURE_CLASS=INCOHERENT_PARTIAL_REAPPLICATION"
echo "CONSUMER_RUNTIME_AT_STABLE_BASE=YES"
echo "ROUTE_SEAM_EDIT_UNCOMMITTED=YES"
echo "CORRECT_ACTION=REVERT_ONLY_UNCOMMITTED_VALIDATION_ROUTE_TEST_SEAM"
echo "NEW_HYPOTHESIS=CONSUMER_ELIGIBILITY_AND_ROUTE_INJECTION_MUST_LAND_TOGETHER"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== REVERT ONLY CURRENT VALIDATION EXPERIMENT FILES ===\n'
git restore -- \
  server/routes/governance-validation-route.ts \
  server/routes/governance-validation-route.test.ts \
  server/validation/production-validation-consumer.test.ts

printf '\n=== VERIFY STABLE BASE RESTORED ===\n'
git diff --exit-code -- \
  server/validation/production-validation-consumer.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.ts \
  server/routes/governance-validation-route.test.ts

npm run check

./node_modules/.bin/tsx --test \
  server/routes/governance-validation-route.test.ts \
  server/validation/production-validation-consumer.test.ts \
  server/validation/production-validation-entry-point.test.ts

printf '\n=== RECOVERY RESULT ===\n'
echo "STABLE_BASE_RESTORED=YES"
echo "HEAD=$EXPECTED_HEAD"
echo "VALIDATION_BASELINE_TYPECHECK=PASS"
echo "VALIDATION_BASELINE_TESTS=PASS"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "NEXT_IMPLEMENTATION_HYPOTHESIS=LAND_CONSUMER_LOADER_ELIGIBILITY_AND_ROUTE_INJECTION_AS_ONE_ATOMIC_CHANGE"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short
