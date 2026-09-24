#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="27dd0d74c"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' LIVE VALIDATION PREREQUISITE — AUTHORITY INSPECTION\n'
printf '====================================================\n\n'

printf '\n=== VALIDATION ROUTE ===\n'
sed -n '1,320p' server/routes/governance-validation-route.ts

printf '\n=== VALIDATION ROUTE TEST ===\n'
sed -n '1,380p' server/routes/governance-validation-route.test.ts

printf '\n=== VALIDATION CLIENT API ===\n'
sed -n '1,320p' client/src/approvals/governanceValidationApi.ts

printf '\n=== VALIDATION CLIENT TEST ===\n'
sed -n '1,380p' client/src/approvals/governanceValidationApi.test.ts

printf '\n=== APPROVALS WORKSPACE VALIDATION WINDOW ===\n'
sed -n '630,735p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== GOVERNANCE VALIDATION WRITE REFERENCES ===\n'
grep -RniE \
  'createGovernanceValidation|insert.*governance_validation|governance_validation_results|VALIDATION_PASSED|RESOLUTION_REQUIRED' \
  server db \
  | head -n 320 || true

printf '\n=== AUTHORIZATION / GATE ARTIFACT REFERENCES ===\n'
grep -RniE \
  'live.*validation|validation.*authorized|authorize.*validation|explicit operator validation|VALIDATION.*AUTHORIZED' \
  docs *.sh server client \
  | head -n 320 || true

printf '\n=== CURRENT FACTS ===\n'
echo "AUTHORIZED_DELEGATION_ID=8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
echo "PACKAGE_ID=pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
echo "PACKAGE_VERSION=1"
echo "CURRENT_VALIDATION_RESULT_COUNT=0"
echo "CURRENT_ENVELOPE_GATE_COUNT=0"
echo "CURRENT_ENVELOPE_COUNT=0"
echo "LIVE_ENVELOPE_ATTEMPT_AUTHORIZED=YES"
echo "LIVE_ENVELOPE_ATTEMPT_CONSUMED=NO"

printf '\n=== INSPECTION RULE ===\n'
echo "LIVE_VALIDATION_MUTATION_DURING_THIS_ACTION=NO"
echo "LIVE_GATE_MUTATION_DURING_THIS_ACTION=NO"
echo "LIVE_ENVELOPE_MUTATION_DURING_THIS_ACTION=NO"
echo "AUTOMATIC_AUTHORITY_INFERENCE=NO"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nLIVE_VALIDATION_PREREQUISITE_AUTHORITY_INSPECTION=COMPLETE\n'
