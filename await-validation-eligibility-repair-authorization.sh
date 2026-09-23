#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="65dabc772"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================\n'
printf '  EXPLICIT IMPLEMENTATION AUTHORIZATION GATE\n'
printf '============================================\n\n'

echo "VALIDATION_ELIGIBILITY_REPAIR=READY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "OPERATOR_TRIGGER_UI=EXCLUDED"
echo "NEW_AUTHORITY=PROHIBITED"

printf '\nTo authorize ONLY the bounded Validation eligibility repair, reply exactly:\n\n'
echo "I authorize the bounded Validation eligibility repair."

printf '\nNo implementation will proceed before that authorization.\n'
