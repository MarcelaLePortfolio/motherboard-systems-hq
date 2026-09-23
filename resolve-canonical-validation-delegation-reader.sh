#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ce3e25c57"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CANONICAL READER RESOLUTION ===\n'
echo "CURRENT_STATE=ATOMIC_REPAIR_BOUNDARY_INSPECTED"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "QUESTION=REUSE_EXISTING_DELEGATION_READER_OR_DEFINE_VALIDATION_SPECIFIC_READER"
echo "SPECULATIVE_DUPLICATE_DB_READER=PROHIBITED"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== EXACT VALIDATION DELEGATION TYPE ===\n'
sed -n '1,70p' db/governance-lifecycle-enforcement.ts

printf '\n=== GOVERNANCE EXECUTION READ REPOSITORY ===\n'
sed -n '1,240p' db/governance-execution-read-repository.ts

printf '\n=== GOVERNANCE EXECUTION READ TESTS ===\n'
sed -n '1,220p' db/governance-execution-read-repository.test.ts

printf '\n=== MISSION READ REPOSITORY ===\n'
sed -n '1,180p' db/mission-read-repository.ts

printf '\n=== CANONICAL PACKAGE DELEGATION READ ===\n'
sed -n '130,215p' db/canonical-package-read-repository.ts

printf '\n=== ALL EXPORTED DELEGATION READ FUNCTIONS ===\n'
grep -RniE \
  --include='*.ts' \
  'export (function|const|type|interface).*([Dd]elegation|GovernanceDelegation)|function .*([Ll]oad|[Rr]ead|[Ff]ind).*([Dd]elegation)' \
  db server 2>/dev/null | head -220

printf '\n=== DATABASE HANDLE CONVENTIONS FOR READ REPOSITORIES ===\n'
grep -RniE \
  --include='*.ts' \
  'new Database|Database\.Database|readonly|fileMustExist|db/main\.db' \
  db/*read*repository*.ts server 2>/dev/null | head -260

printf '\n=== RESOLUTION QUESTIONS ===\n'
echo "Q1=Does an existing exported function load one exact Delegation by delegation_id plus package identity?"
echo "Q2=Does that function return authorization_state?"
echo "Q3=Does it fail closed on missing or mismatched identity?"
echo "Q4=Does it require a caller-supplied database handle or open db/main.db itself?"
echo "Q5=Would reusing it pull unrelated execution-stage requirements into Validation?"
echo "Q6=Can its returned Delegation be passed directly to assertValidationEligible({ delegation })?"
echo "Q7=If not directly reusable, is a narrow exported Delegation read primitive already present elsewhere?"
echo "Q8=Only if no suitable primitive exists, what is the minimum read-only Validation-specific loader?"
echo "Q9=Can that loader remain injectable so unit tests never touch the live database?"
echo "Q10=Can route injection remain a dependency seam only, with zero authority semantics?"

printf '\n=== DECISION RULE ===\n'
echo "IF_EXISTING_EXACT_READER_MATCHES=REUSE_IT"
echo "IF_EXISTING_READER_COUPLES_VALIDATION_TO_LATER_EXECUTION_STATE=DO_NOT_REUSE_CHAIN"
echo "IF_NO_NARROW_READER_EXISTS=DEFINE_MINIMUM_READ_ONLY_VALIDATION_DELEGATION_READER"
echo "NO_RUNTIME_EDIT_UNTIL_READER_DECISION_IS_EVIDENCE_BASED"

printf '\n=== NEXT ATOMIC BOUNDARY IF RESOLVED ===\n'
echo "FILE_1=server/validation/production-validation-consumer.ts"
echo "FILE_2=server/routes/governance-validation-route.ts"
echo "FILE_3=server/validation/production-validation-consumer.test.ts"
echo "FILE_4=server/routes/governance-validation-route.test.ts"
echo "ADDITIONAL_DB_FILE=ONLY_IF_NO_EXISTING_NARROW_READER_CAN_BE_REUSED"
echo "ENTRY_POINT_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nCANONICAL_VALIDATION_DELEGATION_READER_INSPECTION=COMPLETE\n'
