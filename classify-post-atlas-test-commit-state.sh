#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

printf '\n=== VERIFY BRANCH / REMOTE CONVERGENCE ===\n'
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"
printf 'LOCAL_HEAD=%s\n' "$LOCAL_HEAD"
printf 'REMOTE_HEAD=%s\n' "$REMOTE_HEAD"
test "$LOCAL_HEAD" = "$REMOTE_HEAD"

printf '\n=== VERIFY AUTHORIZED TEST IS COMMITTED ===\n'
if git status --short -- "$TEST" | grep -q .; then
  echo "TEST_PATH_STATUS=DIRTY"
else
  echo "TEST_PATH_STATUS=CLEAN"
fi

printf '\n=== RECENT COMMITS ===\n'
git log --oneline -8

printf '\n=== VERIFY TEST CONTENT EXISTS AT HEAD ===\n'
git show "HEAD:$TEST" | grep -n -A24 -B3 \
  'CREATE TABLE IF NOT EXISTS matilda_canonical_packages'

git show "HEAD:$TEST" | grep -n \
  'readAtlasHistoricalObservations\|readAtlasHistoricalTypedObservations\|readAtlasTypedPreexecutionObservations'

printf '\n=== REVALIDATE COMMITTED TEST ===\n'
TSC_STATUS=0
npx tsc --noEmit || TSC_STATUS=$?
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

TEST_STATUS=0
node --test --import tsx "$TEST" || TEST_STATUS=$?
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== VERIFY ATLAS REGRESSION SUITE ===\n'
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

printf 'PERSISTENCE_STATUS=%s\n' "$PERSISTENCE_STATUS"
printf 'ADAPTER_STATUS=%s\n' "$ADAPTER_STATUS"
printf 'AGGREGATOR_STATUS=%s\n' "$AGGREGATOR_STATUS"
printf 'ROUTE_STATUS=%s\n' "$ROUTE_STATUS"

printf '\n=== FINAL CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$TEST_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ -z "$(git status --short -- "$TEST")" ]; then
  echo "ATLAS_LIFECYCLE_TEST_COMMIT=VERIFIED"
  echo "ATLAS_LIFECYCLE_TEST_PUSH=VERIFIED"
  echo "ATLAS_LIFECYCLE_RESTORATION=COMMITTED_AND_REMOTE_CONVERGED"
  echo "BROADER_CORRIDOR_STATUS=ACTIVE"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_GATE=CLASSIFY_LIVE_DOGFOOD_VALIDATION_AUTHORIZATION"
else
  echo "ATLAS_POST_COMMIT_STATE=REQUIRES_DIAGNOSIS"
  echo "BROADER_CORRIDOR_STATUS=ACTIVE"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_ACTION=DIAGNOSE_ONLY_THE_FAILED_CHECK"
fi

echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
