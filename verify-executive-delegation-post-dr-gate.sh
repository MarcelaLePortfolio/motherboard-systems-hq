#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b9dd35bdd"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " EXECUTIVE DELEGATION — POST-DR AUTHORIZATION GATE"
echo "============================================================"
echo "DR_CHECKPOINT=20260922_135026"
echo "PRE_AUTHORIZATION_INVESTIGATION=COMPLETE"
echo "IMPLEMENTATION_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo
echo "Exact authorization sentence:"
echo
echo "I authorize implementation of the bounded Executive Delegation Decision Adapter."
echo
echo "CLEAR_STOPPING_POINT=YES"
