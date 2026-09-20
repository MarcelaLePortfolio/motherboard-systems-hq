#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="7bf89db95"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

mkdir -p docs/checkpoints

cat > docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_STATIC_VALIDATION_CLOSURE.md << 'DOC'
# Draft Revision Approval Handoff — Static Validation Closure

## Status

STATIC_VALIDATION_STATUS=CLOSED
RUNTIME_VALIDATION_STATUS=PENDING
APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN

## Validated Outcomes

- Approval Request revision handoff targeted tests pass: 6/6.
- Server TypeScript build passes.
- Client TypeScript + Vite production build passes.
- The pre-existing `feedbackReady` write-only dead state was removed from `ApprovalsWorkspace.tsx`.
- No approval-handoff semantics were changed by that dead-state removal.
- No canonical boundary, delegation, validation, envelope, execution, governance, or authority semantics were changed.
- Commit `7bf89db95` is the static-validation checkpoint.

## Next Required Validation

Perform the natural runtime flow:

1. Open the pending Approval Review in the running application.
2. Confirm the revised review renders normally.
3. As the human Intent Authority, click Approve.
4. Confirm the prior `draft_revision_id is required` failure does not recur.
5. Confirm a Canonical Package is created from the exact reviewed Draft Revision.
6. Confirm approval does not itself grant delegation or execution authority.
7. Confirm the resolved Approval Request behaves as expected after canonicalization.

Runtime approval must remain a human action and is not automated by this checkpoint.

CLEAR_STOPPING_POINT=YES
DOC

git add -- docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_STATIC_VALIDATION_CLOSURE.md
git commit -m "Record Draft Revision static validation closure"
git push origin feature/support-source-references-runtime
