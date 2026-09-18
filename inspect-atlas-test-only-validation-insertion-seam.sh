#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="cc935edbb"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== CONFIRMED VALIDATION CLASSIFICATION ===\n'
echo "SAFE_EXISTING_HARNESS=CONFIRMED"
echo "TEMPORARY_DATABASE=CONFIRMED"
echo "LOCAL_OLLAMA_STUB=CONFIRMED"
echo "DIRECT_REAL_WORKFLOW_INVOCATION=CONFIRMED"
echo "CURRENT_ATLAS_ASSERTIONS=ABSENT"
echo "PRODUCTION_HISTORICAL_ROWS=0"
echo "NEXT_CAPABILITY_NEEDED=TEST_ONLY_ATLAS_LIFECYCLE_VALIDATION"

printf '\n=== TEST IMPORT / FIXTURE BOUNDARY ===\n'
sed -n '1,230p' "$TEST"

printf '\n=== EXPLICIT TARGET WORKFLOW RESULT BOUNDARY ===\n'
sed -n '430,610p' "$TEST"

printf '\n=== POST-WORKFLOW DATABASE ASSERTION BOUNDARY ===\n'
sed -n '580,720p' "$TEST"

printf '\n=== ATLAS ADAPTER EXPORT CONTRACT ===\n'
sed -n '240,310p' \
  server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== ATLAS AGGREGATOR EXPORT CONTRACT ===\n'
grep -n -B30 -A100 \
  'readAtlasTypedPreexecutionObservations' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== HISTORICAL TABLE SCHEMA ===\n'
sed -n '60,115p' \
  db/atlas-historical-observation-persistence.ts

printf '\n=== DETERMINE MINIMUM TEST-ONLY ASSERTIONS ===\n'
cat <<'CLASSIFICATION'
REQUIRED_ASSERTION_1=workflow persistence creates historical interpretation_evidence observation
REQUIRED_ASSERTION_2=successful draft synthesis creates historical living_draft observation
REQUIRED_ASSERTION_3=historical observations are scoped to explicit target conversation
REQUIRED_ASSERTION_4=typed historical adaptation preserves source and authority status
REQUIRED_ASSERTION_5=merged typed preexecution read suppresses duplicate IEL observation
REQUIRED_ASSERTION_6=merged typed preexecution read preserves distinct Living Draft revision identity
REQUIRED_ASSERTION_7=chronology remains deterministic
REQUIRED_ASSERTION_8=canonical/delegation/validation/envelope/execution authority remains false
CLASSIFICATION

printf '\n=== VERIFY PRODUCT FILES REMAIN UNCHANGED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== NEXT GATE ===\n'
echo "VALIDATION_TYPE=TEST_ONLY"
echo "PROPOSED_MUTATION_PATH=$TEST"
echo "PRODUCT_CODE_CHANGE_REQUIRED=NO"
echo "LIVE_DOGFOOD_REQUIRED_AT_THIS_GATE=NO"
echo "PRODUCTION_DATABASE_MUTATION=NO"
echo "DESTRUCTIVE_CLEANUP=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "NEXT_GATE=AUTHORIZE_BOUNDED_TEST_ONLY_ATLAS_LIFECYCLE_VALIDATION"

printf '\n=== STOP ===\n'
echo "NO MUTATION / NO DOGFOOD EXECUTION / NO CLEANUP"
