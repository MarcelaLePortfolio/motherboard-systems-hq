#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT CHECKPOINT ===\n'
printf 'HEAD='
git rev-parse --short=9 HEAD
echo "PREVIOUS_HYPOTHESIS_SEQUENCE=CLOSED_AFTER_3_FAILURES"
echo "NEW_SOLUTION_CLASS=HISTORICAL_SNAPSHOT_CONTRACT_GAP"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "ATTEMPT_4_AUTHORIZED=NO"

printf '\n=== LIVE LIVING DRAFT CONTRACT ===\n'
sed -n '235,355p' db/matilda-living-draft-runtime.ts

printf '\n=== WORKFLOW LIVING DRAFT CREATION ===\n'
sed -n '500,610p' server/matilda-chat-workflow.ts

printf '\n=== EXACT HISTORICAL SNAPSHOT PAYLOAD ===\n'
grep -n -B25 -A45 \
  'sourceKind: "living_draft"' \
  server/matilda-chat-workflow.ts

printf '\n=== ADAPTER REQUIRED LIVING DRAFT PAYLOAD ===\n'
sed -n '160,255p' \
  server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== UNIT FIXTURE EXPECTATION ===\n'
sed -n '90,180p' \
  server/atlas/atlas-historical-observation-adapter.test.ts

printf '\n=== COMPARE FIELD FLOW ===\n'
grep -n \
  'evidence_entry_ids\|evidenceEntryIds' \
  server/matilda-chat-workflow.ts \
  db/matilda-living-draft-runtime.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-historical-observation-adapter.test.ts \
  || true

printf '\n=== CLASSIFICATION ===\n'
if grep -A40 'sourceKind: "living_draft"' \
     server/matilda-chat-workflow.ts \
     | grep -q 'evidence_entry_ids'; then
  echo "WORKFLOW_HISTORICAL_PAYLOAD_INCLUDES_EVIDENCE_ENTRY_IDS=YES"
  echo "SNAPSHOT_FIELD_OMISSION_CONFIRMED=NO"
else
  echo "WORKFLOW_HISTORICAL_PAYLOAD_INCLUDES_EVIDENCE_ENTRY_IDS=NO"
  echo "SNAPSHOT_FIELD_OMISSION_CONFIRMED=YES"
  echo "LIKELY_FIX_CLASS=MAKE_HISTORICAL_LIVING_DRAFT_SNAPSHOT_MATCH_CANONICAL_LIVING_DRAFT_CONTRACT"
fi

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
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

printf '\n=== STOP ===\n'
echo "PRODUCT_MUTATION=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "ATTEMPT_4_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=DETERMINE_IF_NARROW_SNAPSHOT_FIX_IS_CONFIDENTLY_SUPPORTED"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
