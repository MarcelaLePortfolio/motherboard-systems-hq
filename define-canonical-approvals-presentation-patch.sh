#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="9ec7e90ba"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "============================================================"
echo " INVESTIGATION POINT 14 — MINIMAL PRESENTATION PATCH"
echo "============================================================"
echo "MODE=READ_ONLY_CLASSIFICATION"
echo "PRODUCT_MUTATION=NO"
echo "AUTHORIZED_SCOPE=APPROVED_CANONICAL_PRESENTATION_IN_EXISTING_APPROVALS"

printf '\n=== A. VERIFIED DATA-OWNERSHIP BOUNDARY ===\n'
echo "PROJECT_ID_OWNER=ApprovalRequestProvider"
echo "PENDING_SOURCE=fetchApprovalRequests(projectId)"
echo "APPROVED_SOURCE=fetchCanonicalPackages(projectId)"
echo "NEW_PROJECT_CONTEXT_REQUIRED=NO"
echo "NEW_TOP_LEVEL_WORKSPACE_REQUIRED=NO"
echo "PACKAGES_TAB_REQUIRED=NO"

printf '\n=== B. MINIMAL PROVIDER PATCH ===\n'
echo "TARGET=client/src/approvals/ApprovalRequestProvider.tsx"
echo "ADD=CanonicalPackageReadCollection state"
echo "ADD=fetchCanonicalPackages(projectId) during refresh"
echo "EXPOSE=canonicalCollection"
echo "PRESERVE=existing approval request collection"
echo "PRESERVE=existing projectId ownership"
echo "PRESERVE=single refresh boundary after approval/request-changes"

printf '\n=== C. MINIMAL WORKSPACE PATCH ===\n'
echo "TARGET=client/src/approvals/ApprovalsWorkspace.tsx"
echo "ADD=approved Canonical Package list presentation"
echo "ADD=approved Canonical Package detail presentation"
echo "BADGE=Approved"
echo "PENDING_BADGE=Needs review"
echo "PENDING_ACTIONS=UNCHANGED"
echo "APPROVED_ACTIONS=NONE"
echo "APPROVED_PRESENTATION=READ_ONLY"
echo "PENDING_AND_APPROVED_SEMANTICALLY_DISTINCT=YES"

printf '\n=== D. APPROVED DETAIL FIELD MAPPING ===\n'
echo "TITLE_SOURCE=approved_expected_outcome fallback approved_interpretation"
echo "INTERPRETATION_SOURCE=approved_interpretation"
echo "EXPECTED_OUTCOME_SOURCE=approved_expected_outcome"
echo "WORK_SOURCE=approved_work"
echo "DELIVERABLES_SOURCE=approved_artifacts"
echo "SCOPE_SOURCE=approved_scope"
echo "CONSTRAINTS_SOURCE=approved_constraints"
echo "APPROVAL_ACTOR_SOURCE=approval_actor"
echo "APPROVAL_TIMESTAMP_SOURCE=approval_timestamp"
echo "PACKAGE_ID_SOURCE=package_id"
echo "PACKAGE_VERSION_SOURCE=package_version"
echo "DRAFT_PACKAGE_SOURCE=draft_package_id"
echo "DRAFT_REVISION_SOURCE=draft_revision_id"
echo "CONVERSATION_SOURCE=conversation_id"
echo "LINEAGE_SOURCE=lineage_id"
echo "STATUS_SOURCE=status"

printf '\n=== E. PROHIBITED SEMANTIC CROSSOVER ===\n'
echo "APPROVE_BUTTON_ON_CANONICAL=NO"
echo "REQUEST_CHANGES_ON_CANONICAL=NO"
echo "AVAILABLE_DECISIONS_ON_CANONICAL=NO"
echo "CANONICAL_MUTATION=NO"
echo "CANONICAL_CREATION_CHANGE=NO"
echo "APPROVAL_SEMANTICS_CHANGE=NO"
echo "REQUEST_CHANGES_SEMANTICS_CHANGE=NO"
echo "DELEGATION_CHANGE=NO"
echo "VALIDATION_CHANGE=NO"
echo "ENVELOPE_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"
echo "GOVERNANCE_CHANGE=NO"
echo "AUTHORITY_CHANGE=NO"

printf '\n=== F. MINIMAL TEST SURFACE ===\n'
echo "ADD_TEST=canonicalPackageReadApi.test.ts"
echo "VERIFY=project_id encoded into canonical read request"
echo "VERIFY=non-ok canonical response fails read"
echo "VERIFY=presentation source distinguishes Needs-review requests from Approved canonical packages"
echo "VERIFY=approved presentation contains no decision actions"
echo "SERVER_BUILD_REQUIRED=YES"
echo "CLIENT_BUILD_REQUIRED=YES"

cat > docs/checkpoints/CANONICAL_PACKAGE_APPROVALS_PRESENTATION_PATCH_CLASSIFICATION.md << 'DOC'
# Canonical Package Approvals Presentation — Minimal Patch Classification

## Classification

The existing Approvals / Executive Inbox already owns the pending Approval Request presentation and receives its project binding through `ApprovalRequestProvider`.

The authorized Canonical Package read bridge supplies the corresponding project-scoped approved state.

The minimal presentation patch is therefore:

1. extend `ApprovalRequestProvider` to fetch and expose the read-only Canonical Package collection using the same existing `projectId`;
2. preserve the existing pending Approval Request collection unchanged;
3. present approved Canonical Packages in `ApprovalsWorkspace` as a distinct `Approved` state;
4. provide a read-only approved-package detail presentation;
5. retain `Approve` and `Request Changes` exclusively on pending Approval Requests.

No new project context, top-level workspace, or Packages tab is required.

## Semantic Separation

Pending Approval Requests remain actionable decision objects with the `Needs review` state.

Approved Canonical Packages are authoritative read-only records with the `Approved` state.

Approved Canonical Packages must not expose:

- Approve;
- Request Changes;
- available decisions;
- delegation controls;
- execution controls;
- any mutation action.

## Protected Boundaries

No change is required or authorized to:

- Canonical Package creation or persistence;
- approval semantics;
- Request Changes semantics;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- authority.

Approval remains distinct from delegation and execution.

IMPLEMENTATION_SCOPE=AUTHORIZED_APPROVED_CANONICAL_PRESENTATION
PRODUCT_CODE_CHANGED=NO
DATABASE_MUTATED=NO
AUTHORITY_CHANGED=NO
PACKAGES_TAB_RESTORED=NO
NEXT_ACTION=IMPLEMENT_BOUNDED_APPROVALS_PRESENTATION_PATCH
CLEAR_STOPPING_POINT=YES
DOC

git diff --check

git add -- docs/checkpoints/CANONICAL_PACKAGE_APPROVALS_PRESENTATION_PATCH_CLASSIFICATION.md
git commit -m "Classify canonical Approvals presentation patch"
git push origin "$BRANCH"

echo
echo "============================================================"
echo " INVESTIGATION POINT 14 — COMPLETE"
echo "============================================================"
echo "MINIMAL_PRESENTATION_PATCH_CLASSIFIED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "PACKAGES_TAB_RESTORED=NO"
echo "NEXT_ACTION=IMPLEMENT_BOUNDED_APPROVALS_PRESENTATION_PATCH"
echo "CLEAR_STOPPING_POINT=YES"
