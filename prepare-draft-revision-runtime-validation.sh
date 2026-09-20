#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d95cd1405"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

mkdir -p docs/checkpoints

cat > docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_VALIDATION.md << 'DOC'
# Draft Revision Approval Handoff — Runtime Validation

## Current State

STATIC_VALIDATION_STATUS=CLOSED
RUNTIME_VALIDATION_STATUS=READY
APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN

## Human Runtime Validation Procedure

1. Start or refresh the current Motherboard runtime.
2. Open the pending Approval Review produced by the natural Matilda collaboration.
3. Confirm the revised review renders normally.
4. Click Approve manually as the human Intent Authority.
5. Record whether the previous `draft_revision_id is required` error appears.
6. Confirm whether a Canonical Package is created.
7. Confirm the canonicalized package corresponds to the exact Draft Revision reviewed.
8. Confirm approval does not itself create delegation or execution authority.
9. Confirm the resolved Approval Request transitions out of the pending review state as expected.

## Success Criteria

- `draft_revision_id is required` does not recur.
- The exact reviewed Draft Revision is accepted by the existing Canonical Package boundary.
- A Canonical Package is created.
- No delegation or execution authority is synthesized.
- The Approval Request resolves normally after canonicalization.

## Governance Boundary

The Approve action remains a human action. This validation procedure does not automate, simulate, or pre-authorize approval.

RUNTIME_APPROVAL_AUTOMATED=NO
NEW_AUTHORITY_INTRODUCED=NO
CLEAR_STOPPING_POINT=YES
DOC

git add -- docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_VALIDATION.md
git commit -m "Prepare Draft Revision runtime validation"
git push origin feature/support-source-references-runtime
