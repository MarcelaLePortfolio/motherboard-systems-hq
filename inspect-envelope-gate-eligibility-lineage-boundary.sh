#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="397963863"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE ELIGIBILITY + LINEAGE — INSPECTION\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "CURRENT_STEP=FINAL_PREIMPLEMENTATION_BOUNDARY_INSPECTION"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== PRODUCTION ENVELOPE GATE ENTRY POINT — FULL ===\n'
sed -n '1,260p' server/gate/production-envelope-gate-entry-point.ts

printf '\n=== PRODUCTION ENVELOPE GATE CONSUMER — FULL ===\n'
sed -n '1,240p' server/gate/production-envelope-gate-consumer.ts

printf '\n=== PRODUCTION ENVELOPE GATE ENTRY POINT TEST — FULL ===\n'
sed -n '1,300p' server/gate/production-envelope-gate-entry-point.test.ts

printf '\n=== PRODUCTION ENVELOPE GATE CONSUMER TEST — FULL ===\n'
sed -n '1,260p' server/gate/production-envelope-gate-consumer.test.ts

printf '\n=== GOVERNANCE VALIDATION ROUTE RESPONSE CONTRACT ===\n'
sed -n '1,320p' server/routes/governance-validation-route.ts

printf '\n=== GOVERNANCE VALIDATION ROUTE TEST ===\n'
sed -n '1,360p' server/routes/governance-validation-route.test.ts

printf '\n=== VALIDATION PERSISTENCE IMPLEMENTATION ===\n'
sed -n '800,1085p' db/governance-runtime.ts

printf '\n=== LIFECYCLE ELIGIBILITY ENFORCEMENT ===\n'
sed -n '1,220p' db/governance-lifecycle-enforcement.ts

printf '\n=== SEARCH FOR VALIDATION → GATE ELIGIBILITY CHECK ===\n'
grep -RniE \
  'VALIDATION_PASSED|isValidationPassed|validation.*eligible|eligible.*validation|validation_result_id.*delegation_id|delegation_id.*validation_result_id' \
  server/gate \
  server/routes/governance-envelope-gate-route.ts \
  db/governance-runtime.ts \
  db/governance-lifecycle-enforcement.ts \
  --exclude-dir=node_modules || true

printf '\n=== SEARCH FOR GATE DUPLICATION / EXISTENCE CHECK ===\n'
grep -RniE \
  'governance_envelope_gates|validation_result_id|UNIQUE|already exists|existing.*gate|duplicate' \
  server/gate \
  db/governance-runtime.ts \
  --exclude-dir=node_modules || true

printf '\n=== CURRENT VALIDATION UI ACTION — EXACT REGION ===\n'
sed -n '620,715p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== CURRENT VALIDATION BUTTON — EXACT REGION ===\n'
sed -n '860,920p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== CLIENT VALIDATION RESPONSE TYPE ===\n'
sed -n '1,220p' client/src/approvals/governanceValidationApi.ts

printf '\n=== CLASSIFICATION ===\n'
echo "QUESTION_1=Does Gate entry point itself verify persisted Validation status equals VALIDATION_PASSED?"
echo "QUESTION_2=Does Gate entry point verify package/version/delegation identity against the persisted Validation result?"
echo "QUESTION_3=Does Gate persistence rely only on foreign-key existence rather than semantic eligibility?"
echo "QUESTION_4=Does Validation route response return the created persisted validation_result_id?"
echo "QUESTION_5=Can ApprovalsWorkspace retain that exact returned identity instead of regenerating it?"
echo "QUESTION_6=Is an explicit separate Open Envelope Gate operator action sufficient if eligibility is already enforced?"
echo "QUESTION_7=If eligibility is not enforced at Gate entry, what is the smallest existing read/enforcement primitive that can be reused?"
echo "QUESTION_8=Can the bridge be implemented without modifying Envelope creation, lifecycle, execution, scheduler, or worker code?"

printf '\n=== REQUIRED DECISION RULE ===\n'
echo "IF_GATE_PROVES_ELIGIBILITY=IMPLEMENT_CLIENT_ADAPTER_PLUS_EXPLICIT_OPERATOR_GATE_ACTION_ONLY"
echo "IF_GATE_DOES_NOT_PROVE_ELIGIBILITY=DO_NOT_WIRE_CLIENT_YET"
echo "IF_GATE_DOES_NOT_PROVE_ELIGIBILITY=IDENTIFY_SMALLEST_FAIL_CLOSED_SERVER_ELIGIBILITY_BRIDGE_FIRST"
echo "SPECULATIVE_LAYERING=PROHIBITED"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nENVELOPE_GATE_ELIGIBILITY_LINEAGE_BOUNDARY_INSPECTION=COMPLETE\n'
