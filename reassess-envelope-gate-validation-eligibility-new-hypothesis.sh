#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="bb0ae6e27"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE ELIGIBILITY — NEW HYPOTHESIS REVIEW\n'
printf '====================================================\n\n'

echo "STABLE_BASE_CONFIRMED=$EXPECTED_HEAD"
echo "PREVIOUS_HYPOTHESIS=EXACT_READ_ONLY_VALIDATION_RESULT_ELIGIBILITY_SEAM"
echo "PREVIOUS_HYPOTHESIS_ATTEMPTS=3"
echo "PREVIOUS_HYPOTHESIS_RETRY=PROHIBITED"
echo "CURRENT_ACTION=INVESTIGATION_ONLY"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== ENTRY-POINT AUTHORITY CONTRACT ===\n'
sed -n '1,220p' server/gate/production-envelope-gate-entry-point.ts

printf '\n=== CURRENT CONSUMER ===\n'
sed -n '1,240p' server/gate/production-envelope-gate-consumer.ts

printf '\n=== CURRENT ROUTE ===\n'
sed -n '1,260p' server/routes/governance-envelope-gate-route.ts

printf '\n=== CONSUMER TEST CONTRACT ===\n'
sed -n '1,320p' server/gate/production-envelope-gate-consumer.test.ts

printf '\n=== ROUTE TEST CONTRACT ===\n'
sed -n '1,360p' server/routes/governance-envelope-gate-route.test.ts

printf '\n=== VALIDATION RESULT PERSISTENCE CONTRACT ===\n'
grep -RniE \
  'validation_result_id|validation_status|governance_validation_results|VALIDATION_PASSED' \
  db/governance-runtime.ts \
  db/governance-lifecycle-enforcement.ts \
  server/gate \
  server/routes/governance-envelope-gate-route.ts \
  | head -n 240

printf '\n=== AUTHORITY FLAG CONTRACT ===\n'
grep -RniE \
  'endpoint_authorized|envelope_creation_authorized|execution_authorized|new_authority_introduced' \
  server/gate \
  | head -n 240

printf '\n=== REASSESSMENT CLASSIFICATION ===\n'
echo "KNOWN_CONTRACT_REQUIREMENT=ALL_ENVELOPE_GATE_RESULTS_INCLUDE_ENDPOINT_AUTHORIZED_FALSE"
echo "PATCH_PREVIOUS_ATTEMPT=NO"
echo "NEW_IMPLEMENTATION_HYPOTHESIS_DEFINED=NO"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_DIFFERENT_AND_CLEANER_ELIGIBILITY_BOUNDARY_FROM_EVIDENCE"
echo "IMPLEMENTATION_AUTHORITY_CONSUMED=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "NEW_AUTHORITY=NO"

printf '\nENVELOPE_GATE_ELIGIBILITY_REASSESSMENT_CAPTURED=YES\n'
