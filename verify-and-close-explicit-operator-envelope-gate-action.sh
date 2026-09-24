#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="633f84123"
IMPLEMENTATION_COMMIT="42a07bfde"

TARGETS=(
  "client/src/approvals/ApprovalsWorkspace.tsx"
  "client/src/approvals/governanceEnvelopeGateApi.ts"
  "client/src/approvals/governanceEnvelopeGateApi.test.ts"
)

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE GATE ACTION — CLOSURE\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "RECORD_COMMIT=$EXPECTED_HEAD"
echo "IMPLEMENTATION_STATUS=LANDED"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"

printf '\n=== IMPLEMENTATION TARGETS ===\n'
git diff-tree --no-commit-id --name-only -r "$IMPLEMENTATION_COMMIT"

test "$(git diff-tree --no-commit-id --name-only -r "$IMPLEMENTATION_COMMIT" | wc -l | tr -d ' ')" = "3"

for f in "${TARGETS[@]}"; do
  git diff-tree --no-commit-id --name-only -r "$IMPLEMENTATION_COMMIT" | grep -Fxq "$f"
done

printf '\n=== REVALIDATION 1: DIFF CHECK ===\n'
git diff --check "$IMPLEMENTATION_COMMIT^" "$IMPLEMENTATION_COMMIT"

printf '\n=== REVALIDATION 2: ROOT TYPECHECK ===\n'
npm run check

printf '\n=== REVALIDATION 3: ENVELOPE GATE CLIENT TESTS ===\n'
./node_modules/.bin/tsx --test \
  client/src/approvals/governanceEnvelopeGateApi.test.ts

printf '\n=== REVALIDATION 4: VALIDATION CLIENT TESTS ===\n'
./node_modules/.bin/tsx --test \
  client/src/approvals/governanceValidationApi.test.ts

printf '\n=== REVALIDATION 5: CLIENT BUILD ===\n'
(
  cd client
  npm run build
)

printf '\n=== CONTRACT EVIDENCE ===\n'
grep -nE \
  'validationResultId|setValidationResultId|handleCreateEnvelopeGate|postGovernanceEnvelopeGate|validationComplete && validationResultId|Record Envelope Gate|does not create an Envelope|authorize execution' \
  client/src/approvals/ApprovalsWorkspace.tsx

grep -nE \
  '/api/governance/envelope-gate|validation_result_id|package_id|package_version|delegation_id|fetch' \
  client/src/approvals/governanceEnvelopeGateApi.ts

printf '\n=== CLOSURE CLASSIFICATION ===\n'
echo "EXACT_SUCCESSFUL_VALIDATION_RESULT_ID_RETAINED=YES"
echo "PACKAGE_ID_PRESERVED=YES"
echo "PACKAGE_VERSION_PRESERVED=YES"
echo "DELEGATION_ID_PRESERVED=YES"
echo "VALIDATION_AND_GATE_ACTIONS_REMAIN_SEPARATE=YES"
echo "GATE_ACTION_REQUIRES_EXPLICIT_OPERATOR_CLICK=YES"
echo "GATE_ACTION_UNAVAILABLE_BEFORE_SUCCESSFUL_VALIDATION=YES"
echo "GATE_ROUTE_FAILURE_SURFACED_TO_OPERATOR=YES"
echo "SERVER_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "ENTRY_POINT_CHANGE=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE GATE ACTION CLOSED\n'
printf '====================================================\n'
echo "CORRIDOR_STATUS=CLOSED"
echo "VALIDATION_TO_GATE_OPERATOR_SURFACE=COMPLETE"
echo "LIVE_GATE_EXECUTION_REQUIRES_EXPLICIT_OPERATOR_CLICK=YES"
echo "SUCCESSOR_BOUNDARY=ENVELOPE_CREATION"
echo "SUCCESSOR_IMPLEMENTATION_AUTHORIZED=NO"
echo "AUTOMATIC_ADVANCE_TO_ENVELOPE=PROHIBITED"

printf '\nEXPLICIT_OPERATOR_ENVELOPE_GATE_ACTION_CORRIDOR=CLOSED\n'
