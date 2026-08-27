#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT DECISIONS LIST TITLE SOURCE ==="
echo "RECOVERY_POINT=DR_20260826_171804"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT FINDING ==="
echo "BROAD_TITLE_SEARCH_FOUND_NO_EXPLICIT_decisionTitle_BINDING=YES"
echo "NEXT_STEP=TRACE_ACTUAL_DECISIONS_LIST_DATA_AND_LABEL_RENDERING"
echo "PRESENTATION_CHANGE_AUTHORIZED=NO"

echo
echo "=== APPROVALS WORKSPACE STRUCTURE ==="
sed -n '1,430p' client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== APPROVALS DIRECTORY ==="
find client/src/approvals -maxdepth 2 -type f -print | sort

echo
echo "=== APPROVALS TITLE / LIST RENDERING ==="
rg -n -C 10 \
  'map\(|title|label|name|request|outcome|package|approval|decision|selected|active' \
  client/src/approvals \
  | sed -n '1,520p'

echo
echo "=== SERVER DECISION / APPROVAL TITLE SOURCES ==="
rg -n -C 12 \
  'title|label|decision|approval|requestedOutcome|requested_outcome|expectedOutcome|expected_outcome|packageId|package_id' \
  server db routes \
  --glob '*approval*' \
  --glob '*decision*' \
  --glob '*package*' \
  2>/dev/null | sed -n '1,520p' || true

echo
echo "=== CLASSIFICATION ==="
echo "QUESTION_1=WHAT_EXACT_FIELD_IS_RENDERED_AS_THE_DECISIONS_LIST_TITLE"
echo "QUESTION_2=IS_THE_FIELD_PERSISTED_GENERATED_OR_PRESENTATION_DERIVED"
echo "QUESTION_3=IS_FULL_REQUEST_OR_EXPECTED_OUTCOME_TEXT_CURRENTLY_RENDERED"
echo "QUESTION_4=CAN_COMPACTNESS_REMAIN_PRESENTATION_ONLY"
echo "QUESTION_5=IS_TRUNCATION_OR_DERIVED_DISPLAY_LABEL_THE_SAFEST_BOUNDARY"
echo "TITLE_SOURCE=NOT_YET_CLASSIFIED"
echo "IMPLEMENTATION_STARTED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_TITLE_SOURCE_AND_SHORTEST_SAFE_PRESENTATION_BOUNDARY"

git diff --check
git add inspect-decisions-list-title-source.sh
git commit -m "Inspect decisions list title source"
git push
