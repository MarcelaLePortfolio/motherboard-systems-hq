#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== VERIFY AUTHORIZED ATTEMPT 2 DIFF PRESENT ===\n'
grep -n -A20 -B5 \
  'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' \
  "$TEST"

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TSC_STATUS=$?
set -e
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== AUTHORIZED INTEGRATION TEST ===\n'
set +e
npx tsx --test "$TEST"
TEST_STATUS=$?
set -e
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== ATLAS REGRESSION TESTS ===\n'
set +e
npx tsx --test db/atlas-historical-observation-persistence.test.ts
PERSISTENCE_STATUS=$?

npx tsx --test server/atlas/atlas-historical-observation-adapter.test.ts
ADAPTER_STATUS=$?

npx tsx --test server/atlas/atlas-preexecution-observation-aggregator.test.ts
AGGREGATOR_STATUS=$?

npx tsx --test server/routes/atlas/preexecution.test.ts
ROUTE_STATUS=$?
set -e

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

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== ATTEMPT 2 CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$TEST_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_LIFECYCLE_TEST_ATTEMPT_2=VALIDATED_LOCAL_ONLY"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
  echo "NEXT_GATE=TEST_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_LIFECYCLE_TEST_ATTEMPT_2=FAILED_OR_BLOCKED"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
  echo "NEXT_ACTION=DIAGNOSE_ATTEMPT_2_ONLY"
fi

printf '\n=== AUTHORIZED TEST STATUS ===\n'
git status --short -- "$TEST"

printf '\n=== STOP ===\n'
echo "PRODUCT_MUTATION=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "CLEAR_STOPPING_POINT=YES"
