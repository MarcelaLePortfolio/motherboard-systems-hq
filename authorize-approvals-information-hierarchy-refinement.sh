#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== AUTHORIZE APPROVALS INFORMATION HIERARCHY REFINEMENT ==="
echo "BASELINE_COMMIT=8a75b30e"
echo "RECOVERY_POINT=DR_20260826_092915"
echo "IMPLEMENTATION_AUTHORIZED=YES_NARROWLY"
echo "AUTHORIZED_SCOPE=APPROVALS_PRESENTATION_ONLY"
echo "SERVER_CHANGE_AUTHORIZED=NO"
echo "API_CHANGE_AUTHORIZED=NO"
echo "READ_MODEL_CHANGE_AUTHORIZED=NO"
echo "AUTHORITY_MODEL_CHANGE_AUTHORIZED=NO"
echo "APPROVAL_BEHAVIOR_CHANGE_AUTHORIZED=NO"
echo "REQUEST_CHANGES_BEHAVIOR_CHANGE_AUTHORIZED=NO"
echo "PACKAGES_TAB_REMOVAL_AUTHORIZED=NO"

echo
echo "=== AUTHORIZED PRESENTATION CHANGES ==="
echo "LEFT_PRIMARY=expected_outcome_WITH_interpreted_objective_FALLBACK"
echo "LEFT_SECONDARY=interpreted_objective"
echo "LEFT_STATUS=SINGLE_NEEDS_REVIEW_BADGE"
echo "REMOVE_LEFT=artifactLabel"
echo "REMOVE_LEFT=Pending_BADGE"
echo "REMOVE_LEFT=Approve_Canonical_Package_COPY"

echo "RIGHT_HEADING=Package_Review"
echo "RIGHT_STATUS=SINGLE_NEEDS_REVIEW_BADGE"
echo "RIGHT_SUMMARY=interpreted_objective"
echo "RIGHT_APPROVAL_EFFECT=Living_Draft_to_Canonical_Package"
echo "RIGHT_SECTION=What_you_are_approving"
echo "RIGHT_KEEP=expected_outcome"
echo "RIGHT_KEEP=proposed_work"
echo "RIGHT_KEEP=proposed_artifacts"
echo "RIGHT_KEEP=scope"
echo "RIGHT_KEEP_IF_PRESENT=constraints"
echo "RIGHT_KEEP_IF_PRESENT=open_questions"
echo "RIGHT_KEEP=approve_action"
echo "RIGHT_KEEP=request_changes_action"

echo
echo "=== AUTHORIZED COLLAPSED TECHNICAL DETAIL ==="
echo "COLLAPSE=approval_request_id"
echo "COLLAPSE=draft_package_id"
echo "COLLAPSE=conversation_id"
echo "COLLAPSE=lineage_id"
echo "COLLAPSE=source_draft_status"
echo "COLLAPSE=artifact_position"
echo "COLLAPSE=evidence_entry_ids"

echo
echo "VALIDATION_REQUIRED=CLIENT_BUILD_PLUS_LIVE_VISUAL_REVIEW"
echo "ROLLBACK_BOUNDARY=DR_20260826_092915"
echo "NEXT_ACTION=IMPLEMENT_EXACT_APPROVALS_INFORMATION_HIERARCHY_REFINEMENT_ONLY"
