#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ab3902df9"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== ATTEMPT 1 RESULT ===\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_ATTEMPT=1"
echo "RESULT=STOPPED_FAIL_CLOSED"
echo "REASON=EXACT_INJECTED_DELEGATION_LOADER_SEAM_NOT_PRESENT_IN_CURRENT_CONSUMER"
echo "RUNTIME_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "FAILED_IMPLEMENTATION_ATTEMPTS=1"
echo "CURRENT_REPOSITORY_HEAD=$EXPECTED_HEAD"

printf '\n=== CURRENT VALIDATION CONSUMER ===\n'
sed -n '1,220p' server/validation/production-validation-consumer.ts

printf '\n=== CURRENT VALIDATION ENTRY POINT ===\n'
sed -n '1,300p' server/validation/production-validation-entry-point.ts

printf '\n=== DATABASE HANDLE / FACTORY CONVENTIONS ===\n'
grep -Rni -C 12 -E \
  'new Database|Database\(|main\.db|createDefault.*Repository|createDefault.*Persistence|getDatabase|openDatabase' \
  server db \
  --exclude='*.test.ts' \
  2>/dev/null | head -900 || true

printf '\n=== INJECTED READ DEPENDENCY PATTERNS ===\n'
grep -Rni -C 15 -E \
  'load_.*\?:|load_.*:|load.*\?:|load.*:.*=>|read_.*\?:|repository.*\?:' \
  server \
  --include='*.ts' \
  --exclude='*.test.ts' \
  2>/dev/null | head -900 || true

printf '\n=== EXACT EXISTING DELEGATION QUERY ===\n'
sed -n '89,125p' db/governance-execution-read-repository.ts

printf '\n=== CANONICAL ELIGIBILITY CONTRACT ===\n'
sed -n '94,126p' db/governance-lifecycle-enforcement.ts

printf '\n=== CANONICAL DELEGATION TYPES ===\n'
grep -Rni -C 18 -E \
  'GovernanceDelegation|CreatedGovernanceDelegation|authorization_state: string' \
  db \
  --include='*.ts' \
  2>/dev/null | head -900 || true

printf '\n=== VALIDATION CONSUMER TEST ===\n'
sed -n '1,420p' server/validation/production-validation-consumer.test.ts

printf '\n=== NEIGHBORING CONSUMER PATTERNS ===\n'
find server -type f -name '*consumer.ts' -print | sort | while read -r f
do
  if grep -qE 'load|read|repository|createDefault' "$f"; then
    printf '\n----- %s -----\n' "$f"
    grep -n -C 15 -E \
      'load|read|repository|createDefault|PersistenceFunction|dependencies' \
      "$f" | head -260 || true
  fi
done

printf '\n=== ATTEMPT 2 DECISION QUESTIONS ===\n'
echo "Q1=What exact existing convention constructs a production read dependency?"
echo "Q2=What exact database-opening convention should Validation reuse?"
echo "Q3=What canonical Delegation type satisfies assertValidationEligible?"
echo "Q4=Can a narrow loader reuse the exact delegation_id + package_id + package_version query?"
echo "Q5=Can the loader require exactly one row without loading the execution chain?"
echo "Q6=Can the loader be injectable beside create_governance_validation_result?"
echo "Q7=Can tests inject the loader without touching db/main.db?"
echo "Q8=Can failures prove persistence invocation count remains zero?"
echo "Q9=Can AUTHORIZED success prove persistence invocation count equals one?"
echo "Q10=Is the exact seam sufficiently proven for Attempt 2?"

printf '\n=== SCOPE LOCK ===\n'
echo "OPERATOR_TRIGGER_UI=EXCLUDED"
echo "LIVE_GOVERNANCE_DATA_MUTATION=EXCLUDED"
echo "ROUTE_AUTHORITY_CHANGE=NO"
echo "ENTRY_POINT_AUTHORITY_CHANGE=NO"
echo "LEGACY_RUNTIME_REVIVAL=PROHIBITED"
echo "NEW_AUTHORITY=PROHIBITED"
echo "IMPLEMENTATION_ATTEMPT_2_PERFORMED=NO"

printf '\n=== BUILD PROTOCOL ===\n'
echo "FAILED_ATTEMPTS_CURRENT_HYPOTHESIS=1"
echo "MAX_FAILED_ATTEMPTS=3"
echo "ATTEMPT_2_ALLOWED_ONLY_IF_EXACT_SEAM_PROVEN=YES"
echo "IF_EXACT_SEAM_NOT_PROVEN=DO_NOT_IMPLEMENT"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_ELIGIBILITY_LOADER_SEAM_INSPECTION=COMPLETE\n'
