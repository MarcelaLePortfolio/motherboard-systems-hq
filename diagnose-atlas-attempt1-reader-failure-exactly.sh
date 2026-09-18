#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
LOG="/tmp/atlas-attempt1-exact-sqlite-failure.log"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"

printf '\n=== PRESERVE ATTEMPT 1 STATE ===\n'
test -n "$(git diff --name-only -- "$TEST")"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

printf '\n=== READER CALL GRAPH ===\n'
grep -n -B12 -A24 -E \
  'readAtlasPreExecutionObservations|readAtlasLivingDraftObservations|readAtlasPendingApprovalObservations|readAtlasCanonicalPackageObservations|readAtlasHistoricalTypedObservations' \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  || true

printf '\n=== FIXTURE SCHEMA DEPENDENCIES ===\n'
grep -n -E \
  'CREATE TABLE|matilda_interpretation_evidence_ledger|matilda_living_draft_packages|matilda_canonical_packages|approval' \
  "$TEST" \
  || true

printf '\n=== REPRODUCE ATTEMPT 1 FAILURE ===\n'
rm -f "$LOG"

set +e
NODE_OPTIONS='--trace-uncaught --trace-warnings' \
  npx tsx --test --test-reporter=spec "$TEST" \
  >"$LOG" 2>&1
TEST_STATUS=$?
set -e

printf 'TEST_STATUS=%s\n' "$TEST_STATUS"
cat "$LOG"

printf '\n=== SQLITE EVIDENCE ===\n'
grep -n -B20 -A30 -E \
  'SQLITE_ERROR|no such table|no such column|prepare|Database|matilda_|atlas_' \
  "$LOG" \
  || true

printf '\n=== ROOT-CAUSE CLASSIFICATION ===\n'
if grep -q 'no such table:' "$LOG"; then
  echo "ROOT_CAUSE=MISSING_FIXTURE_TABLE_CONFIRMED"
  printf 'EXACT_FAILURE='
  grep -m1 'no such table:' "$LOG"
  echo "NEXT_FIX_CLASS=TEST_FIXTURE_SCHEMA_ONLY"
elif grep -q 'no such column:' "$LOG"; then
  echo "ROOT_CAUSE=FIXTURE_SCHEMA_COLUMN_DRIFT_CONFIRMED"
  printf 'EXACT_FAILURE='
  grep -m1 'no such column:' "$LOG"
  echo "NEXT_FIX_CLASS=TEST_FIXTURE_SCHEMA_ONLY"
elif grep -q 'SQLITE_ERROR' "$LOG"; then
  echo "ROOT_CAUSE=SQLITE_ERROR_REPRODUCED_WITHOUT_EXACT_SQL_DETAIL"
  echo "NEXT_ACTION=ISOLATE_MERGED_LIVE_READERS_ONE_AT_A_TIME"
else
  echo "ROOT_CAUSE=FAILURE_NOT_REPRODUCED"
  echo "NEXT_ACTION=STOP_AND_REASSESS"
fi

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO ATTEMPT 2 / NO TEST COMMIT / NO TEST PUSH"
