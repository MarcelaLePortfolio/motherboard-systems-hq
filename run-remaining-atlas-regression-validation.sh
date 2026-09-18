#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== PRESERVE VALIDATED STATE ===\n'
echo "ATLAS_FIXTURE_CANONICAL_SCHEMA_RESTORATION=VALIDATED_LOCAL_ONLY"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"

printf '\n=== TYPECHECK ===\n'
TSC_STATUS=0
npx tsc --noEmit || TSC_STATUS=$?
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== LIFECYCLE TEST ===\n'
LIFECYCLE_STATUS=0
node --test --import tsx "$TEST" || LIFECYCLE_STATUS=$?
printf 'LIFECYCLE_STATUS=%s\n' "$LIFECYCLE_STATUS"

printf '\n=== ATLAS REGRESSION TESTS ===\n'

PERSISTENCE_STATUS=0
node --test --import tsx \
  db/atlas-historical-observation-persistence.test.ts \
  || PERSISTENCE_STATUS=$?

ADAPTER_STATUS=0
node --test --import tsx \
  server/atlas/atlas-historical-observation-adapter.test.ts \
  || ADAPTER_STATUS=$?

AGGREGATOR_STATUS=0
node --test --import tsx \
  server/atlas/atlas-preexecution-observation-aggregator.test.ts \
  || AGGREGATOR_STATUS=$?

ROUTE_STATUS=0
node --test --import tsx \
  server/routes/atlas/preexecution.test.ts \
  || ROUTE_STATUS=$?

printf '\n=== STATUS SUMMARY ===\n'
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
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  || PROTECTED_STATUS=$?
printf 'PROTECTED_STATUS=%s\n' "$PROTECTED_STATUS"

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== FINAL CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$LIFECYCLE_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_LIFECYCLE_RESTORATION=FULLY_VALIDATED_LOCAL_ONLY"
  echo "FAILED_HYPOTHESIS_COUNT=1"
  echo "AUTHORIZED_TEST_PATH_ONLY=YES"
  echo "PRODUCT_CODE_CHANGED=NO"
  echo "AUTHORITY_CHANGE=NO"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_GATE=TEST_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_REGRESSION_VALIDATION=FAILED_OR_BLOCKED"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_ACTION=DIAGNOSE_ONLY_THE_EXACT_FAILING_VALIDATION"
fi

printf '\n=== STOP ===\n'
git status --short -- "$TEST"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "PRODUCT_COMMIT_AUTHORIZED=NO"
echo "PRODUCT_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
