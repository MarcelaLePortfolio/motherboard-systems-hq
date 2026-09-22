#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "============================================================"
echo " INVESTIGATION POINT 9 — AUTHORIZED IMPLEMENTATION ATTEMPT 1"
echo "============================================================"
echo "AUTHORIZED_SCOPE=READ_ONLY_CANONICAL_PACKAGE_VISIBILITY"
echo "ATTEMPT_NUMBER=1"
echo "DO_NOT_LAYER_FIXES_ON_FAILURE=YES"
echo

test -f execute-bounded-canonical-visibility-restoration.sh || {
  echo "RESULT=STOPPED"
  echo "FAILURE=EXECUTION_SCRIPT_MISSING"
  exit 1
}

bash execute-bounded-canonical-visibility-restoration.sh

echo
echo "============================================================"
echo " INVESTIGATION POINT 9 — ATTEMPT 1 RESULT"
echo "============================================================"
echo "IMPLEMENTATION_ATTEMPT_1_COMPLETED=YES"
echo "READ_ONLY_BRIDGE_COMMITTED=YES"
echo "AUTHORITY_CHANGED=NO"
echo "PACKAGES_TAB_RESTORED=NO"
echo "NEXT_ACTION=VERIFY_COMMIT_AND_THEN_WIRE_APPROVALS_PRESENTATION"
echo "CLEAR_STOPPING_POINT=YES"
