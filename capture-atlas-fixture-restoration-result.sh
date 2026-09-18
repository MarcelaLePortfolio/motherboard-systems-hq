#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== FIXTURE RESTORATION PRESENCE ===\n'
grep -n -A24 -B3 \
  'CREATE TABLE IF NOT EXISTS matilda_canonical_packages' \
  "$TEST"

printf '\n=== TYPECHECK ===\n'
TSC_STATUS=0
npx tsc --noEmit >/tmp/atlas-tsc.out 2>&1 || TSC_STATUS=$?
tail -n 40 /tmp/atlas-tsc.out || true
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== LIFECYCLE TEST ===\n'
TEST_STATUS=0
node --test --test-reporter=tap --import tsx "$TEST" \
  >/tmp/atlas-lifecycle.out 2>&1 || TEST_STATUS=$?
tail -n 80 /tmp/atlas-lifecycle.out || true
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== PROTECTED PRODUCT PATHS ===\n'
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

printf '\n=== FINAL CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$TEST_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_FIXTURE_CANONICAL_SCHEMA_RESTORATION=VALIDATED_LOCAL_ONLY"
  echo "FAILED_HYPOTHESIS_COUNT=1"
  echo "NEXT_ACTION=RUN_REMAINING_ATLAS_REGRESSION_VALIDATION"
else
  echo "ATLAS_FIXTURE_CANONICAL_SCHEMA_RESTORATION=FAILED_OR_BLOCKED"
  echo "FAILED_HYPOTHESIS_COUNT=2"
  echo "NEXT_ACTION=DIAGNOSE_THIS_EXACT_FAILURE_ONLY"
fi

echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "PRODUCT_COMMIT_AUTHORIZED=NO"
echo "PRODUCT_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
