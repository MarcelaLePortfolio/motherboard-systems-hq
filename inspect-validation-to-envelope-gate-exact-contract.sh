#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="8e630e8b1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== VALIDATION → ENVELOPE GATE EXACT CONTRACT ===\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "CURRENT_STEP=FOCUSED_CONTRACT_INSPECTION"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_ENVELOPE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== EXACT ENVELOPE GATE FILES ===\n'
find server db client/src -type f \
  \( -iname '*envelope*gate*' -o -iname '*gate*envelope*' \) \
  -print | sort

printf '\n=== GOVERNANCE ENVELOPE GATE ROUTE ===\n'
sed -n '1,280p' server/routes/governance-envelope-gate-route.ts

printf '\n=== GOVERNANCE ENVELOPE GATE ROUTE TEST ===\n'
sed -n '1,360p' server/routes/governance-envelope-gate-route.test.ts

printf '\n=== ENVELOPE GATE CONSUMER CANDIDATES ===\n'
for f in \
  server/envelope/production-envelope-gate-consumer.ts \
  server/envelope/production-envelope-gate-entry-point.ts \
  server/envelope/production-envelope-gate-consumer.test.ts \
  server/envelope/production-envelope-gate-entry-point.test.ts
do
  if test -f "$f"; then
    echo
    echo "===== $f ====="
    sed -n '1,360p' "$f"
  else
    echo "ABSENT=$f"
  fi
done

printf '\n=== ALL IMPORTS OF ENVELOPE GATE ROUTE / CONSUMER ===\n'
grep -RniE \
  'governance-envelope-gate-route|production-envelope-gate|createGovernanceEnvelopeGateRouter|consumeProductionEnvelopeGateEntryPoint' \
  server db client/src \
  --exclude-dir=node_modules || true

printf '\n=== ROUTE MOUNT PROOF ===\n'
grep -RniE \
  'createGovernanceEnvelopeGateRouter|governanceEnvelopeGate|envelope-gate' \
  server/index.ts server \
  --exclude='governance-envelope-gate-route.ts' \
  --exclude='governance-envelope-gate-route.test.ts' \
  --exclude-dir=node_modules || true

printf '\n=== ENVELOPE GATE PERSISTENCE CONTRACT ===\n'
grep -RniE \
  'GovernanceEnvelopeGatePersistence|create_governance_envelope_gate|governance_envelope_gates|envelope_gate_id|gate_status' \
  db server \
  --exclude-dir=node_modules \
  | head -n 420 || true

printf '\n=== VALIDATION RESULT CONTRACT / STATUS ===\n'
grep -RniE \
  'validation_result_id|VALIDATION_PASSED|validation_status' \
  db/governance-* \
  server/validation \
  server/envelope \
  --exclude-dir=node_modules \
  | head -n 420 || true

printf '\n=== CURRENT CLIENT VALIDATION ADAPTER ===\n'
sed -n '1,280p' client/src/approvals/governanceValidationApi.ts

printf '\n=== CURRENT APPROVALS VALIDATION ACTION REFERENCES ===\n'
grep -nE \
  'handleValidate|submitGovernanceValidation|validationComplete|validation_result_id|Validate|Validated' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
echo "Q1=Is the production Envelope Gate route already mounted and callable?"
echo "Q2=Does the Gate runtime independently enforce exact Validation-result eligibility?"
echo "Q3=What exact Validation status is eligible for the Gate?"
echo "Q4=Does Gate persistence create only a gate record with zero downstream authority?"
echo "Q5=Does the current Validation response expose the persisted validation_result_id needed by the Gate?"
echo "Q6=Can the current Executive surface retain that returned identity without lifecycle auto-advance?"
echo "Q7=Is the minimum bridge therefore a separate explicit operator Gate action using the existing route?"
echo "Q8=What additional eligibility/read seam, if any, is actually missing server-side?"
echo "Q9=Can implementation avoid changes to Envelope creation entirely?"
echo "Q10=What is the smallest exact file boundary for the authorized implementation?"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_TO_ENVELOPE_GATE_EXACT_CONTRACT_INSPECTION=COMPLETE\n'
