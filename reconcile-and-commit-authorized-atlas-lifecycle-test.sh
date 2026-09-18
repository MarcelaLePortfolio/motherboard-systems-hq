#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"

printf '\n=== RECONCILE CURRENT HEAD ===\n'
printf 'LOCAL_HEAD=%s\n' "$LOCAL_HEAD"
printf 'REMOTE_HEAD=%s\n' "$REMOTE_HEAD"
test "$LOCAL_HEAD" = "$REMOTE_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFY AUTHORIZED TEST RESTORATION ===\n'
test "$(git diff --name-only -- "$TEST")" = "$TEST"
git diff --check -- "$TEST"

git diff -- "$TEST" | grep -q \
  'readAtlasHistoricalObservations'
git diff -- "$TEST" | grep -q \
  'readAtlasHistoricalTypedObservations'
git diff -- "$TEST" | grep -q \
  'readAtlasTypedPreexecutionObservations'
git diff -- "$TEST" | grep -q \
  'CREATE TABLE IF NOT EXISTS matilda_canonical_packages'
git diff -- "$TEST" | grep -q \
  'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger'

printf '\n=== REVALIDATE AUTHORIZED TEST BEFORE COMMIT ===\n'
npx tsc --noEmit
node --test --import tsx "$TEST"
node --test --import tsx db/atlas-historical-observation-persistence.test.ts
node --test --import tsx server/atlas/atlas-historical-observation-adapter.test.ts
node --test --import tsx server/atlas/atlas-preexecution-observation-aggregator.test.ts
node --test --import tsx server/routes/atlas/preexecution.test.ts

printf '\n=== VERIFY PRODUCT PATHS UNCHANGED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== STAGE AUTHORIZED TEST ONLY ===\n'
git add -- "$TEST"
test "$(git diff --cached --name-only)" = "$TEST"
git diff --cached --check

printf '\n=== COMMIT AUTHORIZED TEST ===\n'
git commit -m "Restore Atlas lifecycle historical observation validation"
TEST_HEAD="$(git rev-parse HEAD)"

printf '\n=== PUSH AUTHORIZED TEST COMMIT ===\n'
git push origin "$BRANCH"
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$TEST_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$TEST_HEAD"

printf '\n=== VERIFIED COMPLETE ===\n'
echo "TEST_COMMIT=VERIFIED"
echo "TEST_PUSH=VERIFIED"
echo "TEST_HEAD=$TEST_HEAD"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"
echo "AUTHORIZED_PATH_ONLY=$TEST"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "LIVE_DOGFOOD_EXECUTED=NO"
echo "PRODUCTION_DATABASE_MUTATED=NO"
echo "DESTRUCTIVE_CLEANUP=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_GATE=CLASSIFY_LIVE_DOGFOOD_VALIDATION_AUTHORIZATION"
