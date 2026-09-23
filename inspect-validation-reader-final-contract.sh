#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="44e11dd0e"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CONCLUSION ===\n'
echo "ATOMIC_REPAIR_BOUNDARY=CONFIRMED"
echo "CURRENT_HYPOTHESIS=MINIMUM_EXACT_READ_ONLY_DELEGATION_READER"
echo "CURRENT_HYPOTHESIS_ATTEMPTS=0"
echo "IMPLEMENTATION_AUTHORIZATION=ALREADY_GRANTED"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== EXACT DELEGATION TABLE CONTRACT ===\n'
sqlite3 -readonly db/main.db <<'SQL'
.headers on
.mode column
SELECT
  cid,
  name,
  type,
  "notnull",
  dflt_value,
  pk
FROM pragma_table_info('governance_delegations')
WHERE name IN (
  'delegation_id',
  'project_id',
  'package_id',
  'package_version',
  'authorization_state'
)
ORDER BY cid;

SELECT sql
FROM sqlite_master
WHERE type = 'table'
  AND name = 'governance_delegations';
SQL

printf '\n=== LIFECYCLE ELIGIBILITY API — EXACT ===\n'
grep -n -B12 -A55 \
  'AssertValidationEligibleInput\|assertValidationEligible' \
  db/governance-lifecycle-enforcement.ts

printf '\n=== CURRENT VALIDATION CONSUMER — EXACT ===\n'
sed -n '1,240p' server/validation/production-validation-consumer.ts

printf '\n=== EXISTING EXACT EXECUTION READER ===\n'
sed -n '1,190p' db/governance-execution-read-repository.ts

printf '\n=== READ-ONLY REPOSITORY CONVENTIONS ===\n'
sed -n '1,110p' db/package-read-repository.ts
sed -n '115,175p' db/canonical-package-read-repository.ts

printf '\n=== CURRENT ROUTE CONTRACT ===\n'
sed -n '1,155p' server/routes/governance-validation-route.ts

printf '\n=== IMPLEMENTATION DECISION TARGET ===\n'
echo "IDENTITY=delegation_id+package_id+package_version"
echo "DATABASE=READ_ONLY"
echo "ZERO_ROWS=FAIL_CLOSED"
echo "MULTIPLE_ROWS=FAIL_CLOSED"
echo "AUTHORIZED_REQUIRED=YES"
echo "ELIGIBILITY_BEFORE_PERSISTENCE=YES"
echo "DEFAULT_PRODUCTION_READER=VALIDATION_SPECIFIC_READ_REPOSITORY"
echo "TEST_READER=INJECTABLE"
echo "ENTRY_POINT_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_READER_FINAL_CONTRACT_INSPECTION=COMPLETE\n'
