#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT APPROVALS CONTENT COHERENCE ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== APPROVALS DISPLAY BINDINGS ==="
rg -n -C 4 \
  'interpreted_objective|expected_outcome|proposed_work|proposed_artifacts|in_scope|out_of_scope|constraints|open_questions|What you are approving|Package Review' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  2>/dev/null || true

echo
echo "=== FIELD GENERATION AND READ-MODEL SOURCES ==="
rg -n -C 5 \
  'interpreted_objective|expected_outcome|proposed_work|proposed_artifacts|in_scope|out_of_scope|constraints|open_questions|ApprovalRequestReadModel' \
  client/src server routes db \
  -g '*.ts' -g '*.tsx' \
  2>/dev/null || true

echo
echo "=== CURRENT CLASSIFICATION ==="
echo "PACKAGE_REVIEW_SUMMARY=SPECIFIC_REQUEST_INFORMATION"
echo "EXPECTED_OUTCOME=APPEARS_GENERIC"
echo "PROPOSED_WORK=APPEARS_GENERIC"
echo "DELIVERABLES=APPEARS_GENERIC"
echo "SCOPE=USER_REPORTS_LIKELY_GENERIC"
echo "CONTENT_COHERENCE_GAP=YES"
echo "VISUAL_STYLE_DEFECT=NO"
echo "ROOT_CAUSE=NOT_YET_ESTABLISHED"
echo "PRESENTATION_FIX_AUTHORIZED=NO"
echo "SYNTHESIS_FIX_AUTHORIZED=NO"

echo
echo "NEXT_ACTION=TRACE_ACTUAL_APPROVAL_EVIDENCE_VALUES_AND_THEIR_AUTHORING_SOURCE_TO_DETERMINE_WHETHER_GENERICITY_ORIGINATES_IN_STORED_PACKAGE_CONTENT_OR_REACT_PRESENTATION"
