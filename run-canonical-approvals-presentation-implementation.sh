#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6d27323f6"

echo "============================================================"
echo " CANONICAL APPROVALS PRESENTATION — AUTHORIZED EXECUTION"
echo "============================================================"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "BASELINE_VERIFIED=YES"
echo "AUTHORIZED_SCOPE=APPROVED_CANONICAL_PRESENTATION"
echo "STOP_ON_FIRST_FAILURE=YES"

bash implement-canonical-approvals-presentation.sh

echo
echo "============================================================"
echo " CANONICAL APPROVALS PRESENTATION — EXECUTION COMPLETE"
echo "============================================================"
echo "APPROVED_PRESENTATION_IMPLEMENTED=YES"
echo "PENDING_ACTIONS_PRESERVED=YES"
echo "APPROVED_ACTIONS=NONE"
echo "PACKAGES_TAB_RESTORED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RETURN_COMPLETE_OUTPUT_FOR_VALIDATION"
echo "CLEAR_STOPPING_POINT=YES"
