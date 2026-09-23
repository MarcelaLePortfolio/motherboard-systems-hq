#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="514ed670d"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================\n'
printf ' EXPLICIT OPERATOR VALIDATION ACTION — CLOSED\n'
printf '============================================\n\n'

echo "CLOSURE_COMMIT=$EXPECTED_HEAD"
echo "DELEGATION_TO_VALIDATION_OPERATOR_SURFACE=COMPLETE"
echo "LIVE_VALIDATION_EXECUTION=EXPLICIT_OPERATOR_CLICK_ONLY"
echo "AUTOMATIC_VALIDATION=PROHIBITED"
echo "AUTO_ADVANCE=PROHIBITED"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "NEW_AUTHORITY=NONE"

printf '\n============================================\n'
printf ' VALIDATION → ENVELOPE GATE — AUTHORIZATION REQUIRED\n'
printf '============================================\n\n'

echo "NEXT_SUCCESSOR_BOUNDARY=VALIDATION_TO_ENVELOPE_GATE"
echo "SUCCESSOR_IMPLEMENTATION_AUTHORIZED=NO"
echo "LIVE_ENVELOPE_GATE_INVOCATION_AUTHORIZED=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION_AUTHORIZED=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=PROHIBITED"
echo "AUTOMATIC_ENVELOPE_CREATION=PROHIBITED"
echo "EXECUTION_AUTHORITY=PROHIBITED"
echo "NEW_AUTHORITY=PROHIBITED"

printf '\nTo authorize investigation and bounded implementation of ONLY the Validation → Envelope Gate successor, reply exactly:\n\n'
echo "I authorize the bounded Validation to Envelope Gate implementation."

printf '\nSUCCESSOR_STATUS=BLOCKED_PENDING_USER_AUTHORIZATION\n'
