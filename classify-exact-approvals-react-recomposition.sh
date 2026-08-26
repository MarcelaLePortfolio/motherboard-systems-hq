#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY EXACT APPROVALS REACT RECOMPOSITION ==="
echo "BASELINE_COMMIT=0d98d00b"
echo "RECOVERY_POINT=DR_20260826_092915"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PACKAGES_TAB_REMOVAL_AUTHORIZED=NO"

echo
echo "=== EXISTING DATA SUFFICIENCY ==="
echo "API_CHANGE_REQUIRED=NO"
echo "READ_MODEL_CHANGE_REQUIRED=NO"
echo "DEDICATED_HUMAN_PACKAGE_TITLE_FIELD=NOT_AVAILABLE"
echo "INVENT_TITLE_FROM_TECHNICAL_ID=NO"
echo "HUMAN_READABLE_PRIMARY_FIELD=expected_outcome"
echo "HUMAN_READABLE_SECONDARY_FIELD=interpreted_objective"

echo
echo "=== LEFT PANEL EXACT TARGET ==="
echo "PRIMARY=request.evidence.expected_outcome_WITH_interpreted_objective_FALLBACK"
echo "SECONDARY=request.evidence.interpreted_objective"
echo "STATUS=SINGLE_NEEDS_REVIEW_BADGE"
echo "TIMESTAMP=request.updated_at"
echo "REMOVE_PRIMARY=artifactLabel"
echo "REMOVE_PRIMARY=Pending_BADGE"
echo "REMOVE_PRIMARY=Approve_Canonical_Package_COPY"

echo
echo "=== RIGHT PANEL EXACT TARGET ==="
echo "HEADING=Package_Review"
echo "BADGE=SINGLE_NEEDS_REVIEW_BADGE"
echo "SUMMARY=request.evidence.interpreted_objective"
echo "APPROVAL_EFFECT=Living_Draft_to_Canonical_Package"
echo "SECTION=What_you_are_approving"
echo "KEEP=expected_outcome"
echo "KEEP=proposed_work"
echo "KEEP=proposed_artifacts"
echo "KEEP=scope"
echo "KEEP_IF_PRESENT=constraints"
echo "KEEP_IF_PRESENT=open_questions"
echo "KEEP=approve_action"
echo "KEEP=request_changes_action"

echo
echo "=== COLLAPSED TECHNICAL DETAILS ==="
echo "COLLAPSE=approval_request_id"
echo "COLLAPSE=draft_package_id"
echo "COLLAPSE=conversation_id"
echo "COLLAPSE=lineage_id"
echo "COLLAPSE=source_draft_status"
echo "COLLAPSE=artifact_position"
echo "COLLAPSE=evidence_entry_ids"

echo
echo "=== IMPLEMENTATION BOUNDARY ==="
echo "EXISTING_FIELDS_SUPPORT_RECOMPOSITION=YES"
echo "SERVER_CHANGE_REQUIRED=NO"
echo "API_CHANGE_REQUIRED=NO"
echo "AUTHORITY_MODEL_CHANGE_REQUIRED=NO"
echo "APPROVAL_BEHAVIOR_CHANGE_REQUIRED=NO"
echo "TARGET_EXPERIENCE=HUMAN_DECISION_BRIEF"
echo "NEXT_ACTION=AUTHORIZE_EXACT_PRESENTATION_ONLY_RECOMPOSITION_IF_USER_APPROVES"
