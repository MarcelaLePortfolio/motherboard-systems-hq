#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="054d54102"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

cat > docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_RESULT.md << 'DOC'
# Draft Revision Approval Handoff — Runtime Result

## Human Validation Input

APPROVAL_REVIEW_RENDERED=
APPROVE_CLICKED_BY_HUMAN=
DRAFT_REVISION_ID_ERROR_RECURRED=
CANONICAL_PACKAGE_CREATED=
EXACT_REVIEWED_REVISION_CANONICALIZED=
DELEGATION_CREATED=
EXECUTION_AUTHORITY_CREATED=
APPROVAL_REQUEST_RESOLVED=

## Runtime Evidence

Paste or summarize the observed browser/runtime result here before committing this file.

## Corridor Classification

RUNTIME_VALIDATION_STATUS=PENDING_RESULT
APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN
CORRIDOR_CLOSURE_AUTHORIZED=NO
DOC

git add -- docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_RESULT.md
git commit -m "Record Draft Revision runtime result template"
git push origin feature/support-source-references-runtime
