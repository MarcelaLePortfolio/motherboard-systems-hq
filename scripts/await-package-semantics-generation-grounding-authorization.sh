#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6fd0e44a5"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "============================================================"
echo "🛑 IMPLEMENTATION AUTHORIZATION REQUIRED"
echo "============================================================"
echo
echo "AUTHORIZATION_BOUNDARY_RECORDED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo
echo "To proceed, reply in chat with exactly:"
echo
echo "I authorize narrow Package Semantics generation grounding implementation."
