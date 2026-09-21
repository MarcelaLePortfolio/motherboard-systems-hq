#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="090bf2e6c"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

cat > docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_CLOSURE.md << 'DOC'
# Draft Revision Approval Handoff — Runtime Closure

## Corridor Status

STATIC_VALIDATION_STATUS=CLOSED
RUNTIME_VALIDATION_STATUS=CLOSED
APPROVAL_DEFECT_CORRIDOR_STATUS=CLOSED

## Human Runtime Validation

The pending Approval Review was rendered through the current runtime.

The human Intent Authority manually selected Approve.

The previous `draft_revision_id is required` failure did not recur.

After approval, the pending Approval Request disappeared from the interface.

## Durable Runtime Evidence

Post-approval verification established:

- Pending Approval Request count: 0.
- The reviewed Draft Revision remained durably identifiable as:
  `draft-revision-7d868f8c-1661-4547-8a8e-5eaf5c286736`.
- Exactly one matching Canonical Package was present.
- The Canonical Package references that exact reviewed `draft_revision_id`.
- The Canonical Package status is `canonical_approved`.
- `governance_delegations` row count remained 0.
- `governance_execution_approvals` row count remained 0.

## Defect Resolution

The original runtime failure was caused by runtime-version misalignment: a stale server process was serving an Approval Request that did not contain the newly required Draft Revision identity.

After replacing the stale server with the current built server:

- the live Approval Request exposed `draft_revision_id`;
- the review Draft Revision was persisted;
- the human approval succeeded;
- the exact reviewed revision crossed the existing Canonical Package boundary;
- no delegation or execution authority was synthesized.

No further product-code repair was required after runtime alignment.

## Governance Boundary

Approval remained an explicit human action.

Canonical approval did not create delegation.

Canonical approval did not create execution authority.

No canonical-boundary, delegation, validation, envelope, execution, governance, or authority semantics were expanded by this defect repair.

## Closure

DRAFT_REVISION_APPROVAL_HANDOFF_VALIDATED=YES
EXACT_REVIEWED_REVISION_CANONICALIZED=YES
PENDING_APPROVAL_RESOLVED=YES
DELEGATION_SYNTHESIZED=NO
EXECUTION_AUTHORITY_SYNTHESIZED=NO
APPROVAL_DEFECT_CORRIDOR_STATUS=CLOSED

The Draft Revision approval-handoff defect corridor is closed.

The system may now return to the previously authorized product work concerning removal of the frontend Packages tab while preserving package runtime functionality and authority.

NEXT_ACTION=RETURN_TO_AUTHORIZED_PACKAGES_TAB_FRONTEND_WORK
CLEAR_STOPPING_POINT=YES
DOC

git add -- docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_CLOSURE.md
git commit -m "Close Draft Revision approval defect corridor"
git push origin "$BRANCH"

git add -- record-draft-revision-approval-defect-corridor-closure.sh
git commit -m "Record approval defect corridor closure procedure"
git push origin "$BRANCH"
