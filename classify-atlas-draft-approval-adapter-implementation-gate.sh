#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="04b7da6fc"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS DRAFT / APPROVAL OBSERVATION — IMPLEMENTATION GATE ====="
echo "MODE=CLASSIFICATION_ONLY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== VERIFIED LIVING DRAFT SURFACE ====="
echo "REPOSITORY=createPackageReadRepository"
echo "LIST_API=listLivingDraftPackagesByProject(projectId)"
echo "DETAIL_API=getLivingDraftPackageById(projectId,draftPackageId)"
echo "PROJECT_SCOPE=EXPLICIT"
echo "CONVERSATION_ID=PRESERVED"
echo "LINEAGE_ID=PRESERVED"
echo "AUTHORITY=NON_AUTHORITATIVE"
echo "READ_ONLY_DATABASE=YES"

echo
echo "===== VERIFIED PENDING APPROVAL SURFACE ====="
echo "REPOSITORY=createApprovalRequestRepository"
echo "LIST_API=listPendingCanonicalPackageApprovalsByProject(projectId)"
echo "DETAIL_API=getPendingCanonicalPackageApprovalById(projectId,draftPackageId)"
echo "PROJECT_SCOPE=EXPLICIT"
echo "CONVERSATION_ID=PRESERVED"
echo "LINEAGE_ID=PRESERVED"
echo "PENDING_STATE=DERIVED_FROM_ABSENCE_OF_CANONICAL_PACKAGE"
echo "READ_ONLY_DATABASE=YES"

echo
echo "===== EXCLUDED API ====="
echo "API=getPendingCanonicalPackageApprovalByDraftPackageId(draftPackageId)"
echo "ATLAS_USE=FORBIDDEN"
echo "REASON=NO_EXPLICIT_PROJECT_SCOPE"

echo
echo "===== CANONICAL PACKAGE BOUNDARY ====="
echo "CANONICAL_PACKAGE_EXISTS_AFTER_APPROVAL=YES"
echo "CANONICAL_PACKAGE_AUTHORITY=MUST_REMAIN_DISTINCT_FROM_LIVING_DRAFT"
echo "CURRENT_UNIT=PREEXECUTION_DRAFT_AND_PENDING_APPROVAL_OBSERVATION_ONLY"
echo "CANONICAL_PACKAGE_ADAPTER=NOT_INCLUDED_WITHOUT_SEPARATE_EVIDENCE_AND_SCOPE"

echo
echo "===== MINIMUM IMPLEMENTATION UNIT ====="
echo "UNIT=ATLAS_READ_ONLY_LIVING_DRAFT_AND_PENDING_APPROVAL_ADAPTER"
echo "NEW_DATABASE_SCHEMA=NO"
echo "NEW_PERSISTENCE=NO"
echo "NEW_PRODUCER=NO"
echo "MATILDA_WORKFLOW_CHANGE=NO"
echo "AUTHORITY_TRANSITION_CHANGE=NO"
echo "ATLAS_REASONER_WIRING=NO"
echo "EXECUTION_EVENT_CHANGE=NO"
echo "REUSE_EXISTING_PROJECT_SCOPED_READ_SURFACES=YES"
echo "PRESERVE_CONVERSATION_AND_LINEAGE_IDENTITY=YES"
echo "FAIL_CLOSED_ON_PROJECT_SCOPE_MISMATCH=YES"

echo
echo "===== IMPLEMENTATION AUTHORIZATION GATE ====="
echo "IMPLEMENTATION_READY=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "AUTHORIZATION_REQUIRED=YES"
echo "EXACT_AUTHORIZATION=I authorize implementation of the minimum Atlas Living Draft and pending Approval Request read-only observation adapter."

echo
echo "===== SAFETY BOUNDARY ====="
echo "DOGFOOD_CLEANUP=FROZEN"
echo "ATLAS_EXECUTION_EVENT_COERCION=FORBIDDEN"
echo "PARALLEL_ATLAS_PERSISTENCE=FORBIDDEN"
echo "AUTHORITY_CREATION_BY_OBSERVATION=FORBIDDEN"
echo "SOURCE_MUTATION_BY_OBSERVATION=FORBIDDEN"

echo
echo "===== NEXT ACTION ====="
echo "NEXT_ACTION=AWAIT_EXPLICIT_IMPLEMENTATION_AUTHORIZATION"

echo
echo "===== WORKTREE ====="
git status --short
