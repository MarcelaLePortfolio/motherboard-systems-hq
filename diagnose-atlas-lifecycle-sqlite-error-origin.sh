#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CORRECTED DATABASE-WIRING CLASSIFICATION ===\n'
echo "PROCESS_CHDIR_BEFORE_RUNTIME_REQUIRE=YES"
echo "RUNTIMES_BIND_TO_TEMPORARY_DB=YES"
echo "CONVERSATION_RUNTIME_CREATES_CONVERSATION_TURNS=YES"
echo "PRIOR_MISSING_CONVERSATION_TURNS_HYPOTHESIS=REJECTED"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "NEXT_ACTION=LOCATE_EXACT_SQLITE_ERROR_ORIGIN"

printf '\n=== TEST FAILURE PATHS ===\n'
grep -n -A80 -B30 \
  'catch\|finally\|throw\|runMatildaConversationWorkflow' \
  "$TEST" \
  | head -n 420 || true

printf '\n=== WORKFLOW DATABASE CALL SEQUENCE ===\n'
grep -n -A35 -B20 \
  'createInterpretationEvidenceLedgerEntry\|upsertLivingDraftPackage\|persistAtlasHistoricalObservation\|recordMatildaConversationTurn' \
  server/matilda-chat-workflow.ts \
  | head -n 420 || true

printf '\n=== ATLAS HISTORICAL PERSISTENCE SQL ===\n'
grep -n -A220 -B30 \
  'CREATE TABLE\|INSERT INTO\|UPDATE\|SELECT\|persistAtlasHistoricalObservation' \
  db/atlas-historical-observation-persistence.ts \
  | head -n 520 || true

printf '\n=== TEMP FIXTURE INITIALIZATION ORDER ===\n'
grep -n \
  'interpretationRuntime\|listInterpretationEvidenceLedgerEntries\|database = new Database\|CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' \
  "$TEST" || true

printf '\n=== REPRODUCE FAILURE WITH TAP ===\n'
TEST_STATUS=0
node --test --test-reporter=tap --import tsx "$TEST" || TEST_STATUS=$?
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== REPRODUCE FAILURE WITH SPEC ===\n'
SPEC_STATUS=0
node --test --test-reporter=spec --import tsx "$TEST" || SPEC_STATUS=$?
printf 'SPEC_STATUS=%s\n' "$SPEC_STATUS"

printf '\n=== VERIFY NO NEW MUTATION ===\n'
test -z "$(git diff --cached --name-only)"
git diff --check -- "$TEST"

git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts

printf '\n=== STOP ===\n'
echo "DIAGNOSTIC_ONLY=YES"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_FAILING_SQL_FROM_DIAGNOSTIC_OUTPUT"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
