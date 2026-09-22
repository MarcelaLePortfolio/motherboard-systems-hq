#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0ee81c912"
TARGET="implement-canonical-approvals-presentation.sh"

echo "============================================================"
echo " IMPLEMENTATION EXECUTION POINT — CANONICAL APPROVALS"
echo "============================================================"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$TARGET"

echo "BASELINE_VERIFIED=YES"
echo "IMPLEMENTATION_SCRIPT_PRESENT=YES"
echo "AUTHORIZED_SCOPE=APPROVED_CANONICAL_PRESENTATION"
echo "STOP_ON_FIRST_FAILURE=YES"

bash "$TARGET"

echo
echo "============================================================"
echo " IMPLEMENTATION EXECUTION RETURNED SUCCESSFULLY"
echo "============================================================"
echo "NEXT_ACTION=VERIFY_RUNTIME_CANONICAL_VISIBILITY"
echo "CLEAR_STOPPING_POINT=YES"
