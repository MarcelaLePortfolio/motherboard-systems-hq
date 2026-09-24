#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="80f779fba"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' LIVE ENVELOPE CREATION VALIDATION — AUTHORIZATION REQUIRED\n'
printf '====================================================\n\n'

echo "CURRENT_BOUNDARY=LIVE_ENVELOPE_CREATION_VALIDATION"
echo "CURRENT_BOUNDARY_AUTHORIZED=NO"
echo "LIVE_GOVERNANCE_DB_MUTATION=BLOCKED"
echo "ONE_LIVE_ENVELOPE_ATTEMPT=BLOCKED"
echo "AUTOMATIC_ADVANCE=PROHIBITED"

printf '\nReply exactly in chat:\n\n'
printf 'I authorize one live Envelope creation validation.\n'
