#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="7778e0323"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE GATE — UI SEAM INSPECTION\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"

printf '\n=== CURRENT APPROVALS WORKSPACE VALIDATION ACTION ===\n'
grep -nE \
  'Validate|validation|delegat|governanceValidation|validation_result_id|canonicalCollection|approvedPackages' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  | head -n 320 || true

printf '\n=== APPROVALS WORKSPACE RELEVANT REGION ===\n'
sed -n '1,520p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VALIDATION API CLIENT ===\n'
sed -n '1,260p' client/src/approvals/governanceValidationApi.ts

printf '\n=== VALIDATION API TESTS ===\n'
sed -n '1,320p' client/src/approvals/governanceValidationApi.test.ts

printf '\n=== EXISTING ENVELOPE GATE CLIENT REFERENCES ===\n'
grep -RniE \
  '/api/governance/envelope-gate|Envelope Gate|envelope_gate_id|gate_status|gate_reason|validation_result_id' \
  client/src \
  --include='*.ts' \
  --include='*.tsx' \
  | head -n 360 || true

printf '\n=== SERVER ENVELOPE GATE ROUTE CONTRACT ===\n'
sed -n '1,300p' server/routes/governance-envelope-gate-route.ts

printf '\n=== VALIDATION ROUTE RESPONSE CONTRACT ===\n'
sed -n '1,280p' server/routes/governance-validation-route.ts

printf '\n=== SUCCESSOR DESIGN QUESTIONS ===\n'
echo "Q1=DOES_CURRENT_VALIDATION_ACTION_RETAIN_PERSISTED_VALIDATION_RESULT_ID_AFTER_SUCCESS"
echo "Q2=WHERE_CAN_EXPLICIT_GATE_ACTION_BE_RENDERED_ONLY_AFTER_SUCCESSFUL_OPERATOR_VALIDATION"
echo "Q3=CAN_GATE_CLIENT_POST_EXISTING_PACKAGE_VERSION_DELEGATION_AND_VALIDATION_RESULT_IDENTITIES_WITHOUT_NEW_SERVER_AUTHORITY"
echo "Q4=WHAT_MINIMUM_CLIENT_FILES_AND_TESTS_ARE_REQUIRED"
echo "Q5=CAN_GATE_ACTION_REMAIN_MANUAL_AND_SEPARATE_FROM_VALIDATE_CLICK"

printf '\n=== NONNEGOTIABLE BOUNDARY ===\n'
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "SERVER_ENTRY_POINT_CHANGE=NO"
echo "SERVER_ELIGIBILITY_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=CLASSIFY_MINIMUM_EXPLICIT_OPERATOR_GATE_UI_TARGET_SET"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"

printf '\nEXPLICIT_OPERATOR_ENVELOPE_GATE_UI_SEAM_INSPECTION=COMPLETE\n'
