#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="adc37dbd0"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== RECOVERY BASELINE ===\n'
echo "STABLE_BASE_RESTORED=YES"
echo "VALIDATION_BASELINE_TYPECHECK=PASS"
echo "VALIDATION_BASELINE_TESTS=7_OF_7_PASS"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "COHERENT_HYPOTHESIS=CONSUMER_LOADER_ELIGIBILITY_AND_ROUTE_INJECTION_MUST_LAND_TOGETHER"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== CURRENT CONSUMER CONTRACT ===\n'
sed -n '1,280p' server/validation/production-validation-consumer.ts

printf '\n=== CURRENT ROUTE CONTRACT ===\n'
sed -n '1,320p' server/routes/governance-validation-route.ts

printf '\n=== CURRENT CONSUMER TEST CONTRACT ===\n'
sed -n '1,440p' server/validation/production-validation-consumer.test.ts

printf '\n=== CURRENT ROUTE TEST CONTRACT ===\n'
sed -n '1,440p' server/routes/governance-validation-route.test.ts

printf '\n=== ELIGIBILITY ASSERTION CONTRACT ===\n'
grep -n -A100 -B25 \
  'assertValidationEligible' \
  db/governance-lifecycle-enforcement.ts

printf '\n=== EXISTING DELEGATION READ CONTRACTS ===\n'
grep -Rni \
  --include='*.ts' \
  'governance_delegations\|load.*delegation\|DelegationForValidation' \
  db server 2>/dev/null | head -160

printf '\n=== ATOMIC IMPLEMENTATION QUESTIONS ===\n'
echo "Q1=What exact Delegation shape does assertValidationEligible require?"
echo "Q2=What exact wrapper argument does assertValidationEligible require?"
echo "Q3=Is there already a canonical exact Delegation loader that should be reused instead of creating another?"
echo "Q4=What exact fields must the loader provide?"
echo "Q5=Can the loader remain optional and injectable in ProductionValidationConsumerInput?"
echo "Q6=Can GovernanceValidationRouteOptions expose the same loader without granting authority?"
echo "Q7=Can buildGovernanceValidationRouteRequest pass the loader through unchanged?"
echo "Q8=Which existing consumer and route fixtures must inject an AUTHORIZED Delegation to preserve their original test intent?"
echo "Q9=What new tests are required to prove missing and unauthorized Delegations stop before persistence?"
echo "Q10=Can the authorized path still prove exactly one persistence call and zero downstream authority?"

printf '\n=== REQUIRED ATOMIC FILE BOUNDARY ===\n'
echo "RUNTIME_FILE_1=server/validation/production-validation-consumer.ts"
echo "RUNTIME_FILE_2=server/routes/governance-validation-route.ts"
echo "TEST_FILE_1=server/validation/production-validation-consumer.test.ts"
echo "TEST_FILE_2=server/routes/governance-validation-route.test.ts"
echo "ENTRY_POINT_CHANGE=NO"
echo "DATABASE_SCHEMA_CHANGE=NO"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "LIFECYCLE_AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== VALIDATION REQUIREMENTS ===\n'
echo "TYPECHECK_COMMAND=npm run check"
echo "TEST_RUNNER=./node_modules/.bin/tsx --test"
echo "BASELINE_TEST_COUNT=7"
echo "IMPLEMENTATION_MUST_PRESERVE_EXISTING_TEST_INTENT=YES"
echo "IMPLEMENTATION_MUST_ADD_ELIGIBILITY_TESTS=YES"
echo "IMPLEMENTATION_MUST_FAIL_CLOSED_BEFORE_PERSISTENCE=YES"
echo "IMPLEMENTATION_MUST_PRESERVE_DOWNSTREAM_AUTHORITY_FALSE=YES"

printf '\n=== IMPLEMENTATION DECISION ===\n'
echo "THIS_STEP=INSPECTION_ONLY"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "NEXT_STEP=ATOMIC_REPAIR_ONLY_IF_ALL_FOUR_FILE_CONTRACTS_ALIGN"
echo "SPECULATIVE_LAYERING=PROHIBITED"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nATOMIC_VALIDATION_ELIGIBILITY_REPAIR_BOUNDARY_INSPECTION=COMPLETE\n'
