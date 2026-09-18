#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"

printf '\n=== FAILED HYPOTHESIS STATE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_EXECUTED=NO"
echo "ATTEMPT_2_AUTHORIZED=NO"

printf '\n=== MERGED READER DATABASE PROPAGATION ===\n'
sed -n '198,320p' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== INTERPRETATION-EVIDENCE READ MODEL ===\n'
sed -n '1,180p' \
  server/atlas/atlas-preexecution-read-model.ts

printf '\n=== LEDGER READER DATABASE RESOLUTION ===\n'
grep -n -B25 -A90 -E \
  'listInterpretationEvidenceLedgerEntries|new Database|db/main\.db|databasePath|process\.cwd' \
  db/matilda-interpretation-runtime.ts \
  || true

printf '\n=== OTHER LIVE READERS DATABASE RESOLUTION ===\n'
grep -n -B15 -A80 -E \
  'readAtlasLivingDraftObservations|readAtlasPendingApprovalObservations|new Database|databasePath' \
  server/atlas/atlas-draft-approval-observation.ts \
  || true

grep -n -B15 -A80 -E \
  'readAtlasCanonicalPackageObservations|new Database|databasePath' \
  server/atlas/atlas-canonical-package-observation.ts \
  || true

printf '\n=== ISOLATED FIXTURE DATABASE BINDING ===\n'
grep -n -B25 -A50 -E \
  'temporaryRoot|temporaryDbDirectory|main\.db|new Database|process\.chdir|chdir' \
  "$TEST" \
  || true

printf '\n=== CLASSIFY EXACT SEAM ===\n'

AGGREGATOR_PASSES_DB_TO_IEL=NO
if sed -n '198,270p' \
    server/atlas/atlas-preexecution-observation-aggregator.ts |
   grep -A8 'readAtlasPreExecutionObservations' |
   grep -q 'databasePath'
then
  AGGREGATOR_PASSES_DB_TO_IEL=YES
fi

AGGREGATOR_PASSES_DB_TO_DRAFT=NO
if sed -n '198,270p' \
    server/atlas/atlas-preexecution-observation-aggregator.ts |
   grep -A8 'readAtlasLivingDraftObservations' |
   grep -q 'databasePath'
then
  AGGREGATOR_PASSES_DB_TO_DRAFT=YES
fi

AGGREGATOR_PASSES_DB_TO_CANONICAL=NO
if sed -n '198,270p' \
    server/atlas/atlas-preexecution-observation-aggregator.ts |
   grep -A8 'readAtlasCanonicalPackageObservations' |
   grep -q 'databasePath'
then
  AGGREGATOR_PASSES_DB_TO_CANONICAL=YES
fi

printf 'AGGREGATOR_PASSES_DB_TO_IEL=%s\n' \
  "$AGGREGATOR_PASSES_DB_TO_IEL"
printf 'AGGREGATOR_PASSES_DB_TO_DRAFT=%s\n' \
  "$AGGREGATOR_PASSES_DB_TO_DRAFT"
printf 'AGGREGATOR_PASSES_DB_TO_CANONICAL=%s\n' \
  "$AGGREGATOR_PASSES_DB_TO_CANONICAL"

printf '\n=== DATABASE FILES PRESENT DURING CURRENT REPRODUCTION CONTEXT ===\n'
find . /tmp -maxdepth 4 -type f -name 'main.db' \
  -print 2>/dev/null |
  sort |
  head -100

printf '\n=== EXACT ROOT-CAUSE DECISION ===\n'
if [ "$AGGREGATOR_PASSES_DB_TO_IEL" = "NO" ] && \
   [ "$AGGREGATOR_PASSES_DB_TO_DRAFT" = "YES" ] && \
   [ "$AGGREGATOR_PASSES_DB_TO_CANONICAL" = "YES" ]; then
  echo "ROOT_CAUSE_CLASSIFICATION=DATABASE_BINDING_INCONSISTENCY_CANDIDATE_CONFIRMED"
  echo "OBSERVED_GAP=INTERPRETATION_EVIDENCE_LIVE_READER_DOES_NOT_RECEIVE_MERGED_READER_DATABASE_PATH"
  echo "ATTEMPT_2_FIX_CLASS=PROPAGATE_EXPLICIT_DATABASE_BINDING_THROUGH_IEL_LIVE_READ_SEAM"
  echo "FIXTURE_SCHEMA_EXPANSION_NOT_YET_JUSTIFIED=YES"
else
  echo "ROOT_CAUSE_CLASSIFICATION=NOT_YET_CONFIRMED"
  echo "NEXT_ACTION=INSPECT_EXACT_READER_DATABASE_RESOLUTION_ONLY"
fi

printf '\n=== VERIFY NO NEW MUTATION ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORITY / EXECUTION GATES ===\n'
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "SCHEDULING_AUTHORIZED=NO"
echo "ROUTING_AUTHORIZED=NO"
echo "ORCHESTRATION_AUTHORIZED=NO"
echo "SELF_AUTHORIZATION=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"

printf '\n=== STOP ===\n'
echo "NO ATTEMPT 2 MUTATION / NO TEST COMMIT / NO TEST PUSH"
