#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d498fda3c"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== AUTHORIZED ATOMIC REPAIR STATE ===\n'
echo "IMPLEMENTATION_AUTHORIZATION=ALREADY_GRANTED"
echo "CURRENT_HYPOTHESIS=MINIMUM_EXACT_READ_ONLY_DELEGATION_READER"
echo "CURRENT_HYPOTHESIS_ATTEMPTS=0"
echo "THIS_STEP=FINAL_PRE_IMPLEMENTATION_INSPECTION"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== EXACT GOVERNANCE DELEGATION SCHEMA ===\n'
sqlite3 -readonly db/main.db <<'SQL'
.headers on
.mode column
PRAGMA table_info(governance_delegations);
SQL

printf '\n=== EXISTING READ-ONLY REPOSITORY CONVENTIONS ===\n'
for f in \
  db/package-read-repository.ts \
  db/mission-read-repository.ts \
  db/canonical-package-read-repository.ts \
  db/governance-execution-read-repository.ts
do
  if [ -f "$f" ]; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,260p' "$f"
  fi
done

printf '\n=== VALIDATION LIFECYCLE CONTRACT ===\n'
sed -n '1,120p' db/governance-lifecycle-enforcement.ts

printf '\n=== CURRENT VALIDATION CONSUMER ===\n'
cat server/validation/production-validation-consumer.ts

printf '\n=== CURRENT VALIDATION ROUTE ===\n'
cat server/routes/governance-validation-route.ts

printf '\n=== CURRENT VALIDATION CONSUMER TEST ===\n'
cat server/validation/production-validation-consumer.test.ts

printf '\n=== CURRENT VALIDATION ROUTE TEST ===\n'
cat server/routes/governance-validation-route.test.ts

printf '\n=== VALIDATION ENTRY POINT — PRESERVE ===\n'
cat server/validation/production-validation-entry-point.ts

printf '\n=== DATABASE CONSTRUCTOR PATTERNS ===\n'
grep -RniE \
  --include='*.ts' \
  'new Database\(|readonly: true|fileMustExist: true|db/main\.db' \
  db server 2>/dev/null | head -260

printf '\n=== EXACT DELEGATION QUERY PATTERNS ===\n'
grep -RniE \
  --include='*.ts' \
  'delegation_id.*package_id|package_id.*delegation_id|package_version.*authorization_state|authorization_state.*package_version' \
  db server 2>/dev/null | head -260

printf '\n=== IMPLEMENTATION CONTRACT TO RESOLVE ===\n'
echo "Q1=What exact SQL column types correspond to delegation_id package_id package_version authorization_state?"
echo "Q2=What repository convention should open db/main.db read-only?"
echo "Q3=Should the new reader return null on zero rows and throw on more than one row?"
echo "Q4=What exact exported loader type should the consumer accept?"
echo "Q5=What exact default loader should production use when no test loader is injected?"
echo "Q6=How should the consumer call assertValidationEligible({ delegation }) before invoking the entry point?"
echo "Q7=How should the route thread the optional loader dependency without changing request authority?"
echo "Q8=Which existing success fixtures need an AUTHORIZED Delegation loader to preserve their original intent?"
echo "Q9=Which new tests prove missing and unauthorized Delegations cause zero persistence calls?"
echo "Q10=Can all changes remain confined to one DB reader two runtime files and their tests?"

printf '\n=== REQUIRED IMPLEMENTATION INVARIANTS ===\n'
echo "EXACT_IDENTITY=delegation_id+package_id+package_version"
echo "READ_ONLY_DATABASE=YES"
echo "EXACTLY_ONE_ELIGIBLE_DELEGATION_REQUIRED=YES"
echo "MISSING_FAILS_CLOSED=YES"
echo "AMBIGUOUS_FAILS_CLOSED=YES"
echo "UNAUTHORIZED_FAILS_CLOSED=YES"
echo "ELIGIBILITY_BEFORE_PERSISTENCE=YES"
echo "AUTHORIZED_PATH_PERSISTENCE_CALLS=1"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "ENTRY_POINT_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== REQUIRED IMPLEMENTATION FILE SET ===\n'
echo "FILE_1=db/governance-validation-read-repository.ts"
echo "FILE_2=server/validation/production-validation-consumer.ts"
echo "FILE_3=server/routes/governance-validation-route.ts"
echo "FILE_4=server/validation/production-validation-consumer.test.ts"
echo "FILE_5=server/routes/governance-validation-route.test.ts"
echo "OTHER_RUNTIME_FILES_ALLOWED=NO"

printf '\n=== VALIDATION GATES FOR ATTEMPT 1 ===\n'
echo "GATE_1=git diff --check"
echo "GATE_2=npm run check"
echo "GATE_3=repository-native TSX targeted validation tests"
echo "COMMIT_ONLY_IF_ALL_GATES_PASS=YES"
echo "PUSH_ONLY_AFTER_SUCCESSFUL_COMMIT=YES"
echo "ON_FAILURE=REVERT_ALL_FIVE_IMPLEMENTATION_FILES"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_READER_ATOMIC_IMPLEMENTATION_CONTRACT_INSPECTION=COMPLETE\n'
