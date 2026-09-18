#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CHECKPOINT ===\n'
printf 'HEAD='
git rev-parse --short=9 HEAD
echo "PREVIOUS_FAILED_HYPOTHESIS_SEQUENCE=CLOSED"
echo "NEW_SOLUTION_CLASS=EVIDENCE_ENTRY_IDS_SERIALIZATION_BOUNDARY"
echo "IMPLEMENTATION_AUTHORIZED=NO"

printf '\n=== LIVING DRAFT RECORD TYPE ===\n'
sed -n '1,60p' db/matilda-living-draft-runtime.ts

printf '\n=== LIVING DRAFT RETURN VALUE ===\n'
sed -n '395,465p' db/matilda-living-draft-runtime.ts

printf '\n=== HISTORICAL PERSISTENCE SERIALIZATION ===\n'
sed -n '1,175p' db/atlas-historical-observation-persistence.ts

printf '\n=== HISTORICAL ADAPTER CONTRACT ===\n'
sed -n '165,255p' server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== WORKFLOW SNAPSHOT BOUNDARY ===\n'
sed -n '548,590p' server/matilda-chat-workflow.ts

printf '\n=== EXISTING LIVING DRAFT OBSERVATION CONTRACT ===\n'
sed -n '1,125p' server/atlas/atlas-draft-approval-observation.ts

printf '\n=== SEARCH EVIDENCE ENTRY REPRESENTATIONS ===\n'
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'evidenceEntryIds\|evidence_entry_ids' \
  server/atlas \
  db/atlas-historical-observation-persistence.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-living-draft-runtime.ts \
  | head -n 250

printf '\n=== CONTRACT CLASSIFICATION ===\n'
echo "LIVE_RUNTIME_REPRESENTATION=STRING_ARRAY"
echo "DATABASE_REPRESENTATION=JSON_STRING"
echo "WORKFLOW_HISTORICAL_PAYLOAD_SOURCE=LIVE_RUNTIME_RECORD_SPREAD"
echo "ADAPTER_CURRENT_EXPECTATION=STRING"
echo "CONFIRMED_MISMATCH=YES"
echo "OPEN_QUESTION=WHICH_LAYER_OWNS_NORMALIZATION"

printf '\n=== VERIFY PRODUCT BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "PRODUCT_MUTATION=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_NORMALIZATION_OWNER_FROM_OUTPUT"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
