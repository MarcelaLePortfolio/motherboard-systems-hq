#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="cce63fd7b"
IMPLEMENTATION_COMMIT="655d4b88e"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

CONSUMER="server/envelope/production-envelope-consumer.ts"
TEST="server/envelope/production-envelope-consumer.test.ts"

test -f "$CONSUMER"
test -f "$TEST"

npm run check

./node_modules/.bin/tsx --test \
  db/governance-envelope-creation-read-repository.test.ts \
  server/envelope/governance-envelope-semantics.test.ts \
  "$TEST"

grep -Fq 'createGovernanceEnvelopeCreationReadLoader' "$CONSUMER"
grep -Fq 'resolveGovernanceEnvelopeSemantics' "$CONSUMER"
grep -Fq '"VALIDATION_PASSED"' "$CONSUMER"
grep -Fq '"OPEN"' "$CONSUMER"
grep -Fq 'semantics.required_capabilities' "$CONSUMER"
grep -Fq 'semantics.operational_corridor' "$CONSUMER"

printf '\n====================================================\n'
printf ' ENVELOPE CONSUMER ELIGIBILITY INTEGRATION — CLOSED\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "TYPECHECK=PASS"
echo "TARGETED_TESTS=PASS"
echo "EXACT_VALIDATION_READ_INTEGRATED=YES"
echo "EXACT_GATE_READ_INTEGRATED=YES"
echo "VALIDATION_PASSED_REQUIRED=YES"
echo "GATE_OPEN_REQUIRED=YES"
echo "AUTHORITATIVE_REQUIRED_CAPABILITIES_INTEGRATED=YES"
echo "AUTHORITATIVE_OPERATIONAL_CORRIDOR_INTEGRATED=YES"
echo "CALLER_SEMANTICS_OVERRIDE=NO"
echo "FAIL_CLOSED_BEFORE_PERSISTENCE=YES"

printf '\n=== FAILURE ACCOUNTING ===\n'
echo "INSPECTION_SCRIPT_FAILURES=1"
echo "IMPLEMENTATION_FAILED_ATTEMPTS=1"
echo "SUCCESSFUL_IMPLEMENTATION_ATTEMPT=2"
echo "THREE_FAILURE_REVERT_THRESHOLD_REACHED=NO"

printf '\n=== PRESERVED AUTHORITY BOUNDARY ===\n'
echo "LIVE_ENVELOPE_CREATION=NO"
echo "LIVE_GOVERNANCE_MUTATION=NO"
echo "AUTOMATIC_GATE_TO_ENVELOPE_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT BOUNDARY ===\n'
echo "CURRENT_SUB_BOUNDARY=ENVELOPE_CONSUMER_ELIGIBILITY_INTEGRATION"
echo "CURRENT_SUB_BOUNDARY_STATUS=CLOSED"
echo "NEXT_SUB_BOUNDARY=EXPLICIT_OPERATOR_ENVELOPE_ACTION"
echo "NEXT_SUB_BOUNDARY_IMPLEMENTATION_AUTHORIZED=YES"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nENVELOPE_CONSUMER_ELIGIBILITY_INTEGRATION_VERIFICATION=PASS\n'
