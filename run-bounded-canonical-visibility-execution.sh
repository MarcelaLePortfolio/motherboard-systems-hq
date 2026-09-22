#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ce5ed29c5"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "============================================================"
echo " INVESTIGATION POINT 10 — AUTHORIZED PRODUCT EXECUTION"
echo "============================================================"
echo "EXECUTION_SCRIPT_PRESENT=YES"
echo "AUTHORIZED_SCOPE=READ_ONLY_CANONICAL_PACKAGE_VISIBILITY"
echo "IMPLEMENTATION_ATTEMPT=1"
echo "STOP_ON_FIRST_FAILURE=YES"

bash execute-bounded-canonical-visibility-restoration.sh

echo
echo "============================================================"
echo " INVESTIGATION POINT 10 — EXECUTION RESULT"
echo "============================================================"
echo "PRODUCT_EXECUTION_COMPLETED=YES"
echo "NEXT_ACTION=VERIFY_PRODUCT_COMMIT_AND_APPROVALS_PRESENTATION_BOUNDARY"
echo "CLEAR_STOPPING_POINT=YES"
