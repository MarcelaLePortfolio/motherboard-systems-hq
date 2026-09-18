#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

printf '\n=== ATTEMPT 3 BOUNDARY ===\n'
echo "ATTEMPT_3_AUTHORIZED=YES"
echo "ATTEMPT_3_MUTATION_ALREADY_APPLIED=YES"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "NEW_MUTATION=NO"

printf '\n=== VERIFY AUTHORIZED TEST ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== TYPECHECK ===\n'
TSC_STATUS=0
npx tsc --noEmit || TSC_STATUS=$?
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== AUTHORIZED INTEGRATION TEST ===\n'
TEST_STATUS=0
npx tsx --test "$TEST" || TEST_STATUS=$?
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== ATLAS REGRESSION TESTS ===\n'
PERSISTENCE_STATUS=0
ADAPTER_STATUS=0
AGGREGATOR_STATUS=0
ROUTE_STATUS=0

npx tsx --test \
  db/atlas-historical-observation-persistence.test.ts \
  || PERSISTENCE_STATUS=$?

npx tsx --test \
  server/atlas/atlas-historical-observation-adapter.test.ts \
  || ADAPTER_STATUS=$?

npx tsx --test \
  server/atlas/atlas-preexecution-observation-aggregator.test.ts \
  || AGGREGATOR_STATUS=$?

npx tsx --test \
  server/routes/atlas/preexecution.test.ts \
  || ROUTE_STATUS=$?

printf 'PERSISTENCE_STATUS=%s\n' "$PERSISTENCE_STATUS"
printf 'ADAPTER_STATUS=%s\n' "$ADAPTER_STATUS"
printf 'AGGREGATOR_STATUS=%s\n' "$AGGREGATOR_STATUS"
printf 'ROUTE_STATUS=%s\n' "$ROUTE_STATUS"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
PROTECTED_STATUS=0
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  || PROTECTED_STATUS=$?

printf 'PROTECTED_STATUS=%s\n' "$PROTECTED_STATUS"

printf '\n=== ATTEMPT 3 FINAL CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$TEST_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_LIFECYCLE_TEST_ATTEMPT_3=VALIDATED_LOCAL_ONLY"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
  echo "THREE_FAILED_HYPOTHESIS_LIMIT_REACHED=NO"
  echo "AUTHORIZED_TEST_PATH_ONLY=YES"
  echo "PRODUCT_CODE_CHANGED=NO"
  echo "AUTHORITY_CHANGE=NO"
  echo "NEXT_GATE=TEST_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_LIFECYCLE_TEST_ATTEMPT_3=FAILED"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=3"
  echo "THREE_FAILED_HYPOTHESIS_LIMIT_REACHED=YES"
  echo "NEXT_ACTION=REVERT_TO_LAST_KNOWN_STABLE_TEST_STATE_AND_REASSESS"
fi

printf '\n=== STOP ===\n'
git status --short -- "$TEST"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "CLEAR_STOPPING_POINT=YES"
