#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="36032c1ca"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== PROVEN DEFECT ===\n'
echo "CANONICAL_VALIDATION_ELIGIBILITY_CONTRACT=EXISTS"
echo "VALIDATION_REQUIRES_AUTHORIZED_DELEGATION=YES"
echo "PRODUCTION_VALIDATION_CALL_CHAIN_ELIGIBILITY_CHECK=ABSENT"
echo "PRODUCTION_VALIDATION_CALL_CHAIN_AUTHORIZATION_STATE_CHECK=ABSENT"
echo "CURRENT_PERSISTENCE_ACCEPTS_DELEGATION_ID_AS_TEXT_ONLY=YES"
echo "OPERATOR_TRIGGER_SAFE_TO_EXPOSE_NOW=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== EXACT REPAIR INSERTION BOUNDARIES ===\n'
grep -n -C 18 -E \
  'export function handleGovernanceValidationRouteRequest|consumeProductionValidationEntryPoint|buildGovernanceValidationRouteRequest' \
  server/routes/governance-validation-route.ts || true

grep -n -C 18 -E \
  'export function consumeProductionValidationEntryPoint|createDefaultValidationPersistence' \
  server/validation/production-validation-consumer.ts || true

grep -n -C 20 -E \
  'export function invokeProductionValidationEntryPoint|create_governance_validation_result' \
  server/validation/production-validation-entry-point.ts || true

printf '\n=== EXISTING READ-ONLY DELEGATION QUERY PATTERNS ===\n'
grep -Rni -C 10 \
  'FROM governance_delegations' \
  db server \
  --exclude='*.test.ts' \
  2>/dev/null | head -500 || true

printf '\n=== DATABASE HANDLE / REPOSITORY CONVENTIONS ===\n'
grep -Rni -C 8 -E \
  'new Database|Database\(|main\.db|create.*Repository|open.*Repository' \
  db server \
  --exclude='*.test.ts' \
  2>/dev/null | head -500 || true

printf '\n=== CANONICAL VALIDATION ELIGIBILITY TESTS ===\n'
grep -Rni -C 12 -E \
  'assertValidationEligible|Validation ineligible|Delegation is not authorized' \
  db \
  --include='*.test.ts' \
  2>/dev/null || true

printf '\n=== EXACT MINIMUM REPAIR QUESTIONS ===\n'
echo "Q1=At which existing server boundary can the Delegation be loaded before Validation persistence with the least architectural change?"
echo "Q2=Can the lookup bind delegation_id + package_id + package_version and require exactly one row?"
echo "Q3=Can that row be passed directly to assertValidationEligible without duplicating authorization logic?"
echo "Q4=Can nonexistent or ambiguous Delegation identity fail closed before createGovernanceValidationResult?"
echo "Q5=Can mismatched package_id or package_version fail closed by the same lookup?"
echo "Q6=Can an unauthorized Delegation fail closed through assertValidationEligible?"
echo "Q7=Can existing success behavior remain unchanged for an AUTHORIZED Delegation?"
echo "Q8=Can tests inject the read dependency so route/entry-point tests remain isolated from live db/main.db?"
echo "Q9=Can this repair be completed before and independently from any UI/operator-trigger restoration?"
echo "Q10=What exact files would be modified by the minimum repair?"

printf '\n=== REQUIRED IMPLEMENTATION ORDER ===\n'
echo "STEP_1=REPAIR_SERVER_SIDE_VALIDATION_ELIGIBILITY"
echo "STEP_2=TEST_NONEXISTENT_UNAUTHORIZED_AND_IDENTITY_MISMATCH_FAILURES"
echo "STEP_3=TEST_AUTHORIZED_DELEGATION_SUCCESS"
echo "STEP_4=VERIFY_NO_DOWNSTREAM_AUTHORITY"
echo "STEP_5=ONLY_THEN_REASSESS_OPERATOR_TRIGGER"
echo "UI_TRIGGER_IMPLEMENTATION_IN_THIS_REPAIR=NO"
echo "DATABASE_DATA_MUTATION_IN_THIS_REPAIR=NO"
echo "LEGACY_RUNTIME_REVIVAL=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== AUTHORIZATION STATUS ===\n'
echo "DEFECT_CLASSIFIED=YES"
echo "REPAIR_BOUNDARY_INSPECTION_ONLY=YES"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "IMPLEMENTATION_AUTHORIZATION_REQUIRED_BEFORE_REPAIR=YES"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_ELIGIBILITY_REPAIR_BOUNDARY_CLASSIFICATION=COMPLETE\n'
