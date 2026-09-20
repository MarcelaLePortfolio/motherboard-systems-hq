#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="eb33cb874"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== RUNTIME VALIDATION READY ===\n'
echo "STATIC_VALIDATION_STATUS=CLOSED"
echo "RUNTIME_VALIDATION_STATUS=PENDING_HUMAN_ACTION"
echo "APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN"
echo "NEXT_ACTION=OPEN_PENDING_APPROVAL_REVIEW_AND_CLICK_APPROVE_MANUALLY"
echo "CODE_CHANGE_REQUIRED=NO"
echo "NEW_AUTHORITY_REQUIRED=NO"
echo "CLEAR_STOPPING_POINT=YES"

printf '\n=== RESULT TEMPLATE ===\n'
cat docs/checkpoints/DRAFT_REVISION_APPROVAL_HANDOFF_RUNTIME_RESULT.md
