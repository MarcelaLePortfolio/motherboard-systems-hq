#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c89e7a8c8"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

mkdir -p docs/checkpoints

cat > docs/checkpoints/DRAFT_REVISION_RUNTIME_VALIDATION_READY_CHECKPOINT.md << 'DOC'
# Draft Revision Runtime Validation — Ready Checkpoint

## Bottom Line

The Draft Revision approval handoff has passed targeted tests, the server build, and the client build.

The repository is stable and ready for natural runtime validation.

No further implementation or debugging should occur before that runtime test.

## Current State

STATIC_VALIDATION_STATUS=CLOSED
RUNTIME_VALIDATION_STATUS=PENDING_HUMAN_ACTION
APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN

## What We Are Doing Now

The next action is a natural human runtime test:

1. Open the existing pending Approval Review in the running application.
2. Confirm it renders normally.
3. Click Approve manually as the human Intent Authority.
4. Observe whether the prior `draft_revision_id is required` error recurs.
5. Capture the result before making any further code changes.

## Boundary

CODE_CHANGE_REQUIRED=NO
NEW_AUTHORITY_REQUIRED=NO
RUNTIME_APPROVAL_AUTOMATED=NO

NEXT_ACTION=OPEN_PENDING_APPROVAL_REVIEW_AND_CLICK_APPROVE_MANUALLY
CLEAR_STOPPING_POINT=YES
DOC

git add -- docs/checkpoints/DRAFT_REVISION_RUNTIME_VALIDATION_READY_CHECKPOINT.md
git commit -m "Record Draft Revision runtime ready checkpoint"
git push origin "$BRANCH"
