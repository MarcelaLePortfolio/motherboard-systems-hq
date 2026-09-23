#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="8f4220eee"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== ESTABLISHED FINDINGS ===\n'
echo "POST_DELEGATION_COMPONENT=ApprovedCanonicalPackageBriefing"
echo "DELEGATED_PACKAGE_RENDERING=READ_ONLY"
echo "CLIENT_VALIDATION_API=ABSENT"
echo "PRODUCTION_VALIDATION_ROUTE=MOUNTED"
echo "PRODUCTION_VALIDATION_DOWNSTREAM_AUTHORITY=NONE"
echo "VALIDATION_ELIGIBILITY_FUNCTION=EXISTS"
echo "LIVE_HQ_DELEGATION=AUTHORIZED"
echo "LIVE_HQ_VALIDATION_RESULT=ABSENT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== ROUTE ELIGIBILITY ENFORCEMENT ===\n'
grep -RniE \
  'assertValidationEligible|authorization_state|governance_delegations|delegation.*authorized' \
  server/validation \
  server/routes/governance-validation-route.ts \
  db/governance-runtime.ts \
  2>/dev/null || true

printf '\n=== PRODUCTION VALIDATION CONSUMER ===\n'
sed -n '1,420p' server/validation/production-validation-consumer.ts

printf '\n=== PRODUCTION VALIDATION ENTRY POINT ===\n'
sed -n '1,420p' server/validation/production-validation-entry-point.ts

printf '\n=== VALIDATION ROUTE TESTS ===\n'
sed -n '1,520p' server/routes/governance-validation-route.test.ts

printf '\n=== VALIDATION ENTRY-POINT TESTS ===\n'
sed -n '1,520p' server/validation/production-validation-entry-point.test.ts

printf '\n=== POST-DELEGATION UI SURFACE ===\n'
sed -n '620,880p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== PACKAGE FILTER / SELECTION ===\n'
sed -n '880,1120p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== DELEGATION LOOKUP PRIMITIVES ===\n'
grep -RniE \
  'get.*Delegation|load.*Delegation|find.*Delegation|governance_delegations' \
  db server \
  --exclude='*.test.ts' \
  2>/dev/null | head -500 || true

printf '\n=== VALIDATION STATUS VOCABULARY ===\n'
grep -RniE \
  'VALIDATION_PASSED|VALIDATION_FAILED|validation_status' \
  db server client/src \
  --exclude='*.test.ts' \
  2>/dev/null | head -600 || true

printf '\n=== RESTORATION QUESTIONS ===\n'
echo "Q1=Does the production Validation route verify that the referenced Delegation exists and is AUTHORIZED before persistence?"
echo "Q2=If not, must server-side eligibility enforcement precede any operator-facing trigger?"
echo "Q3=Can an existing Delegation lookup primitive supply that evidence without creating authority?"
echo "Q4=Can the existing ApprovedCanonicalPackageBriefing host an explicit Validate action after Delegation?"
echo "Q5=Can a narrow governanceValidationApi.ts call only POST /api/governance/validation?"
echo "Q6=What canonical validation_status represents successful explicit operator validation?"
echo "Q7=Can tests prove Validation persistence grants no Envelope, Routing, Assignment, lifecycle-transition, or Execution authority?"
echo "Q8=Can the restoration avoid motherboard.sqlite, matilda_governance_validations, and validation_actor?"
echo "Q9=What exact files constitute the minimum bounded implementation?"
echo "Q10=Is the implementation boundary now sufficiently proven to request explicit authorization?"

printf '\n=== REQUIRED GOVERNANCE BOUNDARY ===\n'
echo "APPROVAL_NOT_EQUAL_DELEGATION=REQUIRED"
echo "DELEGATION_NOT_EQUAL_VALIDATION=REQUIRED"
echo "VALIDATION_NOT_EQUAL_ENVELOPE=REQUIRED"
echo "VALIDATION_NOT_EQUAL_EXECUTION=REQUIRED"
echo "AUTOMATIC_DELEGATION_TO_VALIDATION=PROHIBITED"
echo "LEGACY_DATABASE_REVIVAL=PROHIBITED"
echo "NEW_AUTHORITY=PROHIBITED"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_TRIGGER_MINIMUM_RESTORATION_CLASSIFICATION=COMPLETE\n'
