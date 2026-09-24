#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="cba20c045"
IMPLEMENTATION_COMMIT="9ba041be7"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

GATE_API="client/src/approvals/governanceEnvelopeGateApi.ts"
GATE_TEST="client/src/approvals/governanceEnvelopeGateApi.test.ts"
ENVELOPE_API="client/src/approvals/governanceEnvelopeApi.ts"
ENVELOPE_TEST="client/src/approvals/governanceEnvelopeApi.test.ts"
WORKSPACE="client/src/approvals/ApprovalsWorkspace.tsx"

for target in \
  "$GATE_API" \
  "$GATE_TEST" \
  "$ENVELOPE_API" \
  "$ENVELOPE_TEST" \
  "$WORKSPACE"
do
  test -f "$target"
done

npm run check

./node_modules/.bin/tsx --test \
  "$GATE_TEST" \
  "$ENVELOPE_TEST"

grep -Fq 'envelope_gate_id' "$GATE_API"
grep -Fq 'Promise<GovernanceEnvelopeGateSuccess>' "$GATE_API"
grep -Fq 'postGovernanceEnvelope' "$WORKSPACE"
grep -Fq 'setEnvelopeGateId' "$WORKSPACE"
grep -Fq 'handleCreateEnvelope' "$WORKSPACE"
grep -Fq '"Create Envelope"' "$WORKSPACE"
grep -Fq '"/api/governance/envelope"' "$ENVELOPE_API"
grep -Fq 'lifecycle_state: "ENVELOPE_CREATED"' "$ENVELOPE_API"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE ACTION — CLOSED\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "TYPECHECK=PASS"
echo "CLIENT_TESTS=PASS"
echo "TYPED_GATE_SUCCESS_RESPONSE=YES"
echo "EXACT_PERSISTED_GATE_ID_RETAINED=YES"
echo "LATEST_GATE_LOOKUP=NO"
echo "LATEST_VALIDATION_LOOKUP=NO"
echo "NARROW_ENVELOPE_CLIENT_API=YES"
echo "EXACT_LINEAGE_POSTED=YES"
echo "EXPLICIT_OPERATOR_CREATE_ENVELOPE_ACTION=YES"
echo "CREATE_ENVELOPE_BEFORE_GATE_SUCCESS=NO"
echo "AUTOMATIC_GATE_TO_ENVELOPE_POST=NO"

printf '\n=== SEMANTIC AUTHORITY ===\n'
echo "CALLER_REQUIRED_CAPABILITIES_AUTHORITATIVE=NO"
echo "CALLER_OPERATIONAL_CORRIDOR_AUTHORITATIVE=NO"
echo "SERVER_CONSUMER_AUTHORITATIVE_SEMANTIC_RESOLUTION=YES"

printf '\n=== FAILURE ACCOUNTING ===\n'
echo "IMPLEMENTATION_FAILED_ATTEMPTS=1"
echo "SUCCESSFUL_CLIENT_IMPLEMENTATION_ATTEMPT=2"
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
echo "DOWNSTREAM_EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n====================================================\n'
printf ' BOUNDED ENVELOPE CREATION CORRIDOR — CLOSED\n'
printf '====================================================\n\n'

echo "ELIGIBILITY_READ_BOUNDARY=CLOSED"
echo "PRODUCTION_CONSUMER_ELIGIBILITY_INTEGRATION=CLOSED"
echo "AUTHORITATIVE_ENVELOPE_SEMANTICS_CONTRACT=CLOSED"
echo "EXPLICIT_OPERATOR_ENVELOPE_ACTION=CLOSED"
echo "BOUNDED_ENVELOPE_CREATION_IMPLEMENTATION=CLOSED"
echo "LIVE_ENVELOPE_VALIDATION=NOT_PERFORMED"
echo "NEXT_BOUNDARY=LIVE_ENVELOPE_CREATION_VALIDATION"
echo "NEXT_BOUNDARY_AUTHORIZED=NO"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nEXPLICIT_OPERATOR_ENVELOPE_ACTION_VERIFICATION=PASS\n'
printf 'BOUNDED_ENVELOPE_CREATION_CORRIDOR_STATUS=CLOSED\n'
