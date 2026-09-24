#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="4b695ab56"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE — EXISTING READ SEAM INSPECTION\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "CURRENT_HYPOTHESIS=REUSE_EXISTING_LIFECYCLE_VALIDATION_ELIGIBILITY_SEMANTICS_AT_GATE_CONSUMER_BOUNDARY"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== VERIFIED CANDIDATE READ LOCATIONS ===\n'
echo "MISSION_READ_REPOSITORY=db/mission-read-repository.ts"
echo "EXECUTION_READ_REPOSITORY=db/governance-execution-read-repository.ts"
echo "PRIOR_VALIDATION_READER=db/governance-validation-read-repository.ts"

printf '\n=== MISSION READ REPOSITORY ===\n'
sed -n '1,220p' db/mission-read-repository.ts

printf '\n=== GOVERNANCE EXECUTION READ REPOSITORY ===\n'
sed -n '1,260p' db/governance-execution-read-repository.ts

printf '\n=== GOVERNANCE EXECUTION READ TEST CONTRACT ===\n'
sed -n '1,300p' db/governance-execution-read-repository.test.ts

printf '\n=== PRIOR VALIDATION READ REPOSITORY ===\n'
sed -n '1,280p' db/governance-validation-read-repository.ts

printf '\n=== CURRENT VALIDATION CONSUMER REUSE PATTERN ===\n'
sed -n '1,240p' server/validation/production-validation-consumer.ts

printf '\n=== LIFECYCLE VALIDATION-PASSED SEMANTICS ===\n'
sed -n '70,180p' db/governance-lifecycle-enforcement.ts

printf '\n=== EXACT VALIDATION RESULT QUERY SURFACES ===\n'
grep -RniE \
  'SELECT|validation_result_id|validation_status|governance_validation_results' \
  db/mission-read-repository.ts \
  db/governance-execution-read-repository.ts \
  db/governance-validation-read-repository.ts \
  | head -n 320 || true

printf '\n=== READ-ONLY DATABASE CONTRACTS ===\n'
grep -RniE \
  'readonly|fileMustExist|new Database|better-sqlite3' \
  db/mission-read-repository.ts \
  db/governance-execution-read-repository.ts \
  db/governance-validation-read-repository.ts \
  | head -n 260 || true

printf '\n=== REUSE CLASSIFICATION ===\n'
echo "QUESTION_1=EXISTING_EXPORTED_EXACT_VALIDATION_RESULT_READER_PRESENT_OR_ABSENT"
echo "QUESTION_2=EXISTING_READER_MATCHES_REQUIRED_RESULT_PACKAGE_VERSION_DELEGATION_IDENTITY_OR_NOT"
echo "QUESTION_3=REUSE_WOULD_IMPORT_EXECUTION_SEMANTICS_OR_NOT"
echo "QUESTION_4=NARROW_EXTENSION_OF_EXISTING_READ_REPOSITORY_POSSIBLE_OR_NOT"
echo "QUESTION_5=NEW_READER_ACTUALLY_REQUIRED_OR_NOT"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=CLASSIFY_REUSE_VS_NARROW_EXTENSION_FROM_INSPECTED_CONTRACTS"
echo "NEW_READER_CREATION=BLOCKED_PENDING_CLASSIFICATION"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"

printf '\nEXISTING_VALIDATION_READ_SEAM_INSPECTION=COMPLETE\n'
