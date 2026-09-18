#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== RESET CHECKPOINT ===\n'
echo "PREVIOUS_HYPOTHESIS_SEQUENCE=CLOSED_AFTER_3_FAILURES"
echo "NEW_SOLUTION_CLASS=HISTORICAL_LIVING_DRAFT_CONTRACT_REASSESSMENT"
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION=NO"

printf '\n=== CURRENT REPOSITORY STATE ===\n'
git status --short
printf 'HEAD='
git rev-parse --short=9 HEAD

printf '\n=== FIND EVIDENCE_ENTRY_IDS CONTRACT ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=client/dist \
  'evidence_entry_ids\|evidenceEntryIds' \
  db server \
  || true

printf '\n=== HISTORICAL PERSISTENCE CONTRACT ===\n'
sed -n '1,420p' \
  db/atlas-historical-observation-persistence.ts

printf '\n=== HISTORICAL ADAPTER CONTRACT ===\n'
sed -n '1,360p' \
  server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== HISTORICAL PERSISTENCE TEST FIXTURES ===\n'
sed -n '1,460p' \
  db/atlas-historical-observation-persistence.test.ts

printf '\n=== HISTORICAL ADAPTER TEST FIXTURES ===\n'
sed -n '1,460p' \
  server/atlas/atlas-historical-observation-adapter.test.ts

printf '\n=== LIVING DRAFT OBSERVATION PRODUCER ===\n'
sed -n '1,460p' \
  server/atlas/atlas-draft-approval-observation.ts

printf '\n=== LIVING DRAFT PACKAGE SCHEMA / WRITERS ===\n'
grep -Rni -B8 -A24 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=client/dist \
  'matilda_living_draft_packages' \
  db server \
  || true

printf '\n=== HISTORICAL LIVING DRAFT PERSIST CALLS ===\n'
grep -Rni -B12 -A30 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=client/dist \
  'persistAtlasHistoricalObservation\|living_draft' \
  db server \
  | grep -E \
    'persistAtlasHistoricalObservation|living_draft|evidence_entry_ids|evidenceEntryIds|payload|snapshot|source' \
  || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
cat <<'CLASSIFY'
QUESTION_1=Does the canonical live Living Draft source actually contain evidence_entry_ids?
QUESTION_2=Does historical persistence preserve that field when snapshotting a Living Draft?
QUESTION_3=Does the adapter require a field that historical persistence never promised?
QUESTION_4=Do adapter unit fixtures contain evidence_entry_ids even though real workflow-produced historical records do not?
QUESTION_5=Is evidence_entry_ids semantically required for Living Draft identity/provenance, or merely assumed by the adapter?
CLASSIFY

printf '\n=== VERIFY PRODUCT BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/atlas/atlas-draft-approval-observation.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "ATTEMPT_4_AUTHORIZED=NO"
echo "PRODUCT_MUTATION=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_EVIDENCE_ENTRY_IDS_SOURCE_OF_TRUTH_FROM_OUTPUT"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
