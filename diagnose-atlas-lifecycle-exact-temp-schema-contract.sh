#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== FAILURE CHECKPOINT ===\n'
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "CURRENT_FAILURE=SQLITE_ERROR"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"

printf '\n=== EXACT FIXTURE TABLE DEFINITIONS ===\n'
grep -n -A45 -B5 \
  'CREATE TABLE IF NOT EXISTS matilda_' \
  "$TEST" || true

printf '\n=== CONVERSATION TURN RUNTIME SCHEMA ===\n'
grep -n -A180 -B25 \
  'CREATE TABLE.*matilda_conversation_turns\|interpretation_entry_id\|ensure.*Conversation' \
  db/matilda-conversation-runtime.ts \
  | head -n 420 || true

printf '\n=== LIVING DRAFT BACKFILL SQL CONTRACT ===\n'
grep -n -A95 -B20 \
  'requiredTables\|resolveOwnership\|json_each\|interpretation_entry_id' \
  db/matilda-living-draft-runtime.ts \
  | head -n 260 || true

printf '\n=== IEL RUNTIME SCHEMA CONTRACT ===\n'
grep -n -A180 -B25 \
  'CREATE TABLE.*matilda_interpretation_evidence_ledger\|ensure.*Interpretation\|entry_id' \
  db/matilda-interpretation-runtime.ts \
  | head -n 420 || true

printf '\n=== FIXTURE TABLE/COLUMN INVENTORY ===\n'
grep -nE \
  'CREATE TABLE|entry_id|interpretation_entry_id|project_id|conversation_id|evidence_entry_ids' \
  "$TEST" \
  | head -n 420 || true

printf '\n=== STATIC CONTRACT CLASSIFICATION ===\n'
if grep -q 'interpretation_entry_id' "$TEST"; then
  echo "FIXTURE_REFERENCES_INTERPRETATION_ENTRY_ID=YES"
else
  echo "FIXTURE_REFERENCES_INTERPRETATION_ENTRY_ID=NO"
fi

if grep -q 'CREATE TABLE IF NOT EXISTS matilda_conversation_turns' "$TEST"; then
  echo "FIXTURE_CREATES_CONVERSATION_TURNS=YES"
else
  echo "FIXTURE_CREATES_CONVERSATION_TURNS=NO"
fi

if grep -q 'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' "$TEST"; then
  echo "FIXTURE_CREATES_IEL=YES"
else
  echo "FIXTURE_CREATES_IEL=NO"
fi

printf '\n=== VERIFY NO NEW MUTATION ===\n'
git diff --check -- "$TEST"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts

printf '\n=== STOP ===\n'
echo "DIAGNOSTIC_ONLY=YES"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "NEXT_ACTION=CLASSIFY_EXACT_TEMP_SCHEMA_VS_RUNTIME_SQL_MISMATCH"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO TEST MUTATION / NO PRODUCT MUTATION"
