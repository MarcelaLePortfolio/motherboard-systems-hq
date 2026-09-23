#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b6b1ac4d1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== PRIOR CLASSIFICATION ===\n'
echo "VALIDATION_TRIGGER_HOST=ApprovedCanonicalPackageBriefing"
echo "DELEGATED_PACKAGES_CURRENTLY_FILTERED_FROM_APPROVED_LIST=YES"
echo "CLIENT_VALIDATION_API=ABSENT"
echo "VALIDATION_PASSED=CANONICAL_SUCCESS_STATUS"
echo "PRODUCTION_VALIDATION_DOWNSTREAM_AUTHORITY=NONE"
echo "AUTHORIZED_DELEGATION_ENFORCEMENT=NOT_YET_PROVEN"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== EXACT VALIDATION CALL CHAIN ===\n'
grep -n -C 12 -E \
  'handleGovernanceValidationRouteRequest|invokeProductionValidationEntryPoint|create_governance_validation_result|assertValidationEligible|delegation_id|authorization_state' \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-entry-point.ts \
  server/validation/production-validation-consumer.ts \
  2>/dev/null || true

printf '\n=== VALIDATION PERSISTENCE PRECONDITIONS ===\n'
sed -n '830,970p' db/governance-runtime.ts

printf '\n=== CANONICAL ELIGIBILITY CONTRACT ===\n'
sed -n '1,220p' db/governance-lifecycle-enforcement.ts

printf '\n=== EXISTING DELEGATION READ PRIMITIVES ===\n'
sed -n '80,145p' db/governance-execution-read-repository.ts
sed -n '140,205p' db/canonical-package-read-repository.ts

printf '\n=== VALIDATION TEST ELIGIBILITY COVERAGE ===\n'
grep -n -C 8 -E \
  'AUTHORIZED|authorization_state|ineligible|delegation|VALIDATION_PASSED|downstream_governance_authorized|new_authority_introduced' \
  server/routes/governance-validation-route.test.ts \
  server/validation/production-validation-entry-point.test.ts \
  server/validation/production-validation-consumer.test.ts \
  2>/dev/null || true

printf '\n=== DIRECT SAFETY CHECK CLASSIFICATION ===\n'
if grep -q 'assertValidationEligible' \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-entry-point.ts \
  server/validation/production-validation-consumer.ts 2>/dev/null
then
  echo "DIRECT_ELIGIBILITY_CALL=FOUND"
else
  echo "DIRECT_ELIGIBILITY_CALL=ABSENT"
fi

if grep -qE 'authorization_state|AUTHORIZED' \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-entry-point.ts \
  server/validation/production-validation-consumer.ts 2>/dev/null
then
  echo "DIRECT_AUTHORIZATION_STATE_CHECK=FOUND"
else
  echo "DIRECT_AUTHORIZATION_STATE_CHECK=ABSENT"
fi

printf '\n=== DECISION BOUNDARY ===\n'
echo "IF_ELIGIBILITY_CHECK_ABSENT=DO_NOT_EXPOSE_OPERATOR_TRIGGER"
echo "REUSE_EXISTING_ELIGIBILITY_CONTRACT=PREFERRED"
echo "AUTOMATIC_VALIDATION=PROHIBITED"
echo "VALIDATION_WITHOUT_AUTHORIZED_DELEGATION=PROHIBITED"
echo "VALIDATION_TO_ENVELOPE_AUTO_ADVANCE=PROHIBITED"
echo "LEGACY_RUNTIME_REVIVAL=PROHIBITED"
echo "NEW_AUTHORITY=PROHIBITED"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== WORKTREE — PRESERVE ===\n'
git status --short

printf '\nVALIDATION_ROUTE_ELIGIBILITY_GAP_INSPECTION=COMPLETE\n'
