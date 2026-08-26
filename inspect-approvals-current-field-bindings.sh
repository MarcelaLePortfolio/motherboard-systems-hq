#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT APPROVALS CURRENT FIELD BINDINGS ==="
echo "BASELINE_COMMIT=e0463650"
echo "RECOVERY_POINT=DR_20260826_092915"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PACKAGES_TAB_REMOVAL_AUTHORIZED=NO"

echo
echo "=== LEFT PANEL FIELD BINDINGS ==="
rg -n -C 4 \
  'artifactLabel|interpreted_objective|expected_outcome|updated_at|DecisionBadge|Approve Canonical Package' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== RIGHT HEADER AND APPROVAL EFFECT BINDINGS ==="
rg -n -C 5 \
  'executive-briefing__header|executive-briefing__status-line|executive-briefing__question|executive-briefing__notice|executive-briefing__transition|Current state|Proposed state' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== DECISION BRIEF CONTENT BINDINGS ==="
rg -n -C 5 \
  'Requested outcome|Proposed work|Proposed artifacts|Scope|Constraints|Open questions|Technical details|evidence_entry_ids|draft_package_id|conversation_id|lineage_id|source_draft_status' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== TARGET CHECK ==="
echo "CHECK=WHICH_EXISTING_FIELDS_CAN_SUPPLY_HUMAN_TITLE_SUMMARY_APPROVAL_EFFECT_AND_COLLAPSED_TECHNICAL_DETAIL_WITHOUT_API_CHANGE"
echo "NEXT_ACTION=CLASSIFY_EXACT_REACT_RECOMPOSITION_FROM_THESE_BINDINGS_BEFORE_IMPLEMENTATION_AUTHORIZATION"
