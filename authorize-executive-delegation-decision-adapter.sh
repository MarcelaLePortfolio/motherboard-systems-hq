#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="dfc8e2d19"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " EXECUTIVE DELEGATION DECISION ADAPTER — AUTHORIZATION REQUIRED"
echo "============================================================"
echo
echo "Exact authorization sentence:"
echo
echo "I authorize implementation of the bounded Executive Delegation Decision Adapter."
echo
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CLEAR_STOPPING_POINT=YES"
