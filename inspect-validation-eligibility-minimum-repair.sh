#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="1490d85d9"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CONCLUSION ===\n'
echo "DEFECT_CONFIRMED=YES"
echo "MINIMUM_REPAIR_CLASS=SERVER_SIDE_VALIDATION_ELIGIBILITY_GATE"
echo "OPERATOR_TRIGGER_REMAINS_BLOCKED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_DATA_MUTATION_AUTHORIZED=NO"

printf '\n=== EXACT DELEGATION READ PATTERN ===\n'
sed -n '90,140p' db/governance-execution-read-repository.ts

printf '\n=== CANONICAL ELIGIBILITY CONTRACT ===\n'
grep -Rni -C 25 \
  'assertValidationEligible' \
  db server \
  --include='*.ts' \
  2>/dev/null || true

printf '\n=== VALIDATION CONSUMER ===\n'
sed -n '1,180p' server/validation/production-validation-consumer.ts

printf '\n=== VALIDATION ENTRY POINT ===\n'
sed -n '1,240p' server/validation/production-validation-entry-point.ts

printf '\n=== EXISTING VALIDATION TEST SEAMS ===\n'
for f in \
  server/validation/production-validation-consumer.test.ts \
  server/validation/production-validation-entry-point.test.ts \
  server/routes/governance-validation-route.test.ts
do
  if [ -f "$f" ]; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,360p' "$f"
  fi
done

printf '\n=== MINIMUM REPAIR DECISION QUESTIONS ===\n'
echo "Q1=Which existing boundary can load the exact Delegation before Validation persistence without changing route semantics?"
echo "Q2=Can the loader require exactly one row matching delegation_id + package_id + package_version?"
echo "Q3=Can the resulting canonical Delegation record be passed directly to assertValidationEligible?"
echo "Q4=Can missing, mismatched, ambiguous, or unauthorized Delegations fail before createGovernanceValidationResult?"
echo "Q5=Can the read dependency be injected so tests never depend on live db/main.db?"
echo "Q6=Which exact files would require modification for this repair?"
echo "Q7=Can every existing downstream authority flag remain false?"
echo "Q8=Can this repair remain completely independent of operator-trigger/UI restoration?"

printf '\n=== REQUIRED REPAIR TEST MATRIX ===\n'
echo "AUTHORIZED_EXACT_DELEGATION=SUCCESS"
echo "UNAUTHORIZED_DELEGATION=FAIL_CLOSED_BEFORE_PERSISTENCE"
echo "MISSING_DELEGATION=FAIL_CLOSED_BEFORE_PERSISTENCE"
echo "PACKAGE_ID_MISMATCH=FAIL_CLOSED_BEFORE_PERSISTENCE"
echo "PACKAGE_VERSION_MISMATCH=FAIL_CLOSED_BEFORE_PERSISTENCE"
echo "AMBIGUOUS_IDENTITY=FAIL_CLOSED_IF_STRUCTURALLY_POSSIBLE"
echo "DOWNSTREAM_AUTHORITY_ON_SUCCESS=NONE"
echo "DOWNSTREAM_AUTHORITY_ON_FAILURE=NONE"

printf '\n=== SCOPE GUARD ===\n'
echo "IMPLEMENTATION_PERFORMED=NO"
echo "DATABASE_DATA_MUTATION=NO"
echo "OPERATOR_TRIGGER_IMPLEMENTATION=NO"
echo "LEGACY_RUNTIME_REVIVAL=NO"
echo "NEW_AUTHORITY=NO"
echo "NEXT_GATE=EXPLICIT_IMPLEMENTATION_AUTHORIZATION_AFTER_BOUNDARY_CONFIRMATION"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_ELIGIBILITY_MINIMUM_REPAIR_INSPECTION=COMPLETE\n'
