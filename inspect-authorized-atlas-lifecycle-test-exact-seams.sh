#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

printf '\n=== VERIFY CURRENT CONVERGED BASELINE ===\n'
git fetch origin "$BRANCH"

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"
printf 'RELATIONSHIP='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORIZATION CLASSIFICATION ===\n'
echo "TEST_MUTATION_AUTHORIZED=YES"
echo "AUTHORIZED_PATH=$TEST"
echo "PRODUCT_CODE_CHANGE_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_EXPANSION_AUTHORIZED=NO"

printf '\n=== EXACT IMPORT BLOCK ===\n'
sed -n '1,120p' "$TEST"

printf '\n=== EXACT TEMPORARY DATABASE SETUP ===\n'
grep -n -B35 -A90 \
  'temporaryRoot\|process.chdir\|main.db' \
  "$TEST" | head -280

printf '\n=== EXACT WORKFLOW INVOCATIONS ===\n'
grep -n -B45 -A100 \
  'runMatildaConversationWorkflow' \
  "$TEST"

printf '\n=== EXACT EXISTING RESULT ASSERTIONS ===\n'
grep -n -B35 -A120 \
  'canonical_package_created\|delegation_authorized\|validation_authorized\|envelope_authorized\|execution_authorized' \
  "$TEST"

printf '\n=== EXACT DATABASE ASSERTION / CLEANUP TAIL ===\n'
tail -260 "$TEST"

printf '\n=== HISTORICAL ADAPTER TYPES / EXPORTS ===\n'
sed -n '1,330p' \
  server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== MERGED TYPED READER SIGNATURE / MERGE LOGIC ===\n'
grep -n -B45 -A170 \
  'readAtlasTypedPreexecutionObservations' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== HISTORICAL RECORD SCHEMA / READER SIGNATURE ===\n'
grep -n -B35 -A130 \
  'readAtlasHistoricalObservations' \
  db/atlas-historical-observation-persistence.ts

printf '\n=== REQUIRED AUTHORIZED ASSERTIONS ===\n'
cat <<'ASSERTIONS'
ASSERTION_1=historical interpretation_evidence persisted by real shared workflow
ASSERTION_2=historical living_draft persisted when draft synthesis succeeds
ASSERTION_3=historical records scoped to explicit target conversation
ASSERTION_4=typed historical adaptation preserves source and authority
ASSERTION_5=merged reader suppresses duplicate IEL by entryId
ASSERTION_6=merged reader preserves Living Draft revision identity by draftPackageId plus updatedAt
ASSERTION_7=merged chronology deterministic
ASSERTION_8=canonical/delegation/validation/envelope/execution authority remains false
ASSERTIONS

printf '\n=== VERIFY ONLY AUTHORIZED TEST MAY CHANGE NEXT ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

test -z "$(git diff -- "$TEST")"

printf '\n=== IMPLEMENTATION READINESS ===\n'
echo "AUTHORIZED_IMPLEMENTATION_ATTEMPT=1"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=0"
echo "NEXT_ACTION=IMPLEMENT_EXACT_TEST_ONLY_ASSERTIONS_FROM_VERIFIED_SEAMS"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "NO MUTATION / NO COMMIT / NO PUSH"
