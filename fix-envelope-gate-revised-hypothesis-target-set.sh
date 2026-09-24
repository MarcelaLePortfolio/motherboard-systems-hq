#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ce1466126"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE — FIX REVISED TARGET SET\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "CURRENT_HYPOTHESIS=EXTRACT_NARROW_EXACT_VALIDATION_RESULT_READ_PRIMITIVE_AND_REUSE_LIFECYCLE_ELIGIBILITY_SEMANTICS"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== EXACT LIFECYCLE TYPES ===\n'
sed -n '1,220p' db/governance-lifecycle-enforcement.ts

printf '\n=== EXACT EXECUTION READ VALIDATION SHAPE ===\n'
sed -n '1,230p' db/governance-execution-read-repository.ts

printf '\n=== ENVELOPE GATE CONSUMER INPUT TYPE ===\n'
sed -n '1,220p' server/gate/production-envelope-gate-consumer.ts

printf '\n=== ENVELOPE GATE ROUTE OPTIONS + REQUEST BUILDER ===\n'
sed -n '1,240p' server/routes/governance-envelope-gate-route.ts

printf '\n=== VALIDATION CONSUMER DEPENDENCY-INJECTION PATTERN ===\n'
sed -n '1,220p' server/validation/production-validation-consumer.ts

printf '\n=== VALIDATION ROUTE DEPENDENCY-INJECTION PATTERN ===\n'
sed -n '1,260p' server/routes/governance-validation-route.ts

printf '\n=== TEST INJECTION PATTERNS ===\n'
sed -n '1,260p' server/gate/production-envelope-gate-consumer.test.ts
sed -n '1,320p' server/routes/governance-envelope-gate-route.test.ts

printf '\n=== TARGET-SET DECISION QUESTIONS ===\n'
echo "Q1=CAN_CONSUMER_DEFINE_OPTIONAL_EXACT_VALIDATION_LOADER_WITH_DEFAULT_READONLY_IMPLEMENTATION"
echo "Q2=IF_YES_ROUTE_THREADING_REQUIRED_FOR_TEST_INJECTION_AND_ROUTE_LEVEL_FAIL_CLOSED_PROOF"
echo "Q3=CAN_EXISTING_LIFECYCLE_MODULE_EXPORT_NARROW_VALIDATION_RESULT_ELIGIBILITY_ASSERTION_WITHOUT_CHANGING_EXISTING_SEMANTICS"
echo "Q4=SHOULD_READ_PRIMITIVE_BE_EXTRACTED_FROM_EXECUTION_READ_REPOSITORY_INTO_NEUTRAL_REPOSITORY_AND_REUSED_BY_EXECUTION_READER"
echo "Q5=WHAT_EXACT_TEST_FILES_ARE_REQUIRED_TO_PROVE_NO_EXECUTION_OR_ENVELOPE_AUTHORITY"

printf '\n=== NONNEGOTIABLE BOUNDARY ===\n'
echo "ENTRY_POINT_CHANGE=NO"
echo "ENTRY_POINT_AUTHORITY_FLAGS_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "CLIENT_CHANGE=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=CLASSIFY_EXACT_ATOMIC_TARGET_SET_FROM_TYPES_AND_INJECTION_SEAMS"
echo "REVISED_HYPOTHESIS_ATTEMPT_1=NOT_STARTED"

printf '\nREVISED_HYPOTHESIS_TARGET_SET_INSPECTION=COMPLETE\n'
