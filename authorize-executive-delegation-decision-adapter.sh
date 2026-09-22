#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="10e3c4245"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " EXECUTIVE DELEGATION DECISION ADAPTER — AUTHORIZATION GATE"
echo "============================================================"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"
echo
echo "Reply exactly:"
echo
echo "I authorize implementation of the bounded Executive Delegation Decision Adapter."
echo
echo "CLEAR_STOPPING_POINT=YES"
