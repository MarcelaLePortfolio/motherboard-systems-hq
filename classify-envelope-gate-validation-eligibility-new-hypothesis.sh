#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="1a3a12a22"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE ELIGIBILITY — NEW HYPOTHESIS\n'
printf '====================================================\n\n'

echo "STABLE_HEAD=$EXPECTED_HEAD"
echo "PREVIOUS_HYPOTHESIS=RETIRED_AFTER_3_ATTEMPTS"
echo "PATCH_FORWARD=NO"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== EVIDENCE CLASSIFICATION ===\n'
echo "ENTRY_POINT_OWNS_CANONICAL_GATE_PERSISTENCE=YES"
echo "ENTRY_POINT_AUTHORITY_FLAGS_ARE_COMPLETE_AND_SHARED=YES"
echo "ENTRY_POINT_ENDPOINT_AUTHORIZED=FALSE"
echo "ROUTE_ENDPOINT_AUTHORIZED=TRUE"
echo "CONSUMER_CURRENTLY_ONLY_ADAPTS_ROUTE_INPUT_TO_ENTRY_POINT=YES"
echo "VALIDATION_RESULT_FOREIGN_KEY_EXISTS=YES"
echo "FOREIGN_KEY_DOES_NOT_PROVE_VALIDATION_PASSED=YES"
echo "LIFECYCLE_ENFORCEMENT_ALREADY_DEFINES_VALIDATION_PASSED_SEMANTICS=YES"

printf '\n=== DIFFERENT AND CLEANER HYPOTHESIS ===\n'
echo "NEW_HYPOTHESIS=REUSE_EXISTING_LIFECYCLE_VALIDATION_ELIGIBILITY_SEMANTICS_AT_GATE_CONSUMER_BOUNDARY"
echo "NEW_READ_SEAM_REQUIRED=TO_BE_PROVEN"
echo "NEW_STATUS_RULE_REQUIRED=NO"
echo "DUPLICATE_VALIDATION_PASSED_SEMANTICS=PROHIBITED"
echo "ENTRY_POINT_CHANGE=NO"
echo "ENTRY_POINT_AUTHORITY_FLAGS_CHANGE=NO"
echo "ROUTE_ENDPOINT_AUTHORITY_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "CLIENT_CHANGE=NO"

printf '\n=== REQUIRED NEXT INSPECTION ===\n'
printf '%s\n' \
  "Determine whether governance-lifecycle-enforcement already exports a reusable exact Validation eligibility function or repository-backed prerequisite contract." \
  "Determine what persisted Validation Result read primitive already exists anywhere in db/ or server/." \
  "Determine whether the consumer can consume that existing primitive without changing the entry-point contract."

printf '\n=== EXISTING LIFECYCLE ELIGIBILITY IMPLEMENTATION ===\n'
sed -n '1,230p' db/governance-lifecycle-enforcement.ts

printf '\n=== EXISTING VALIDATION READ PRIMITIVES ===\n'
grep -RniE \
  'get.*validation|load.*validation|find.*validation|read.*validation|validation.*repository|governance_validation_results' \
  db server \
  --include='*.ts' \
  --include='*.mjs' \
  | head -n 300 || true

printf '\n=== EXISTING LIFECYCLE ENFORCEMENT CALLERS ===\n'
grep -RniE \
  'isValidationPassed|Envelope creation ineligible|governance-lifecycle-enforcement' \
  db server \
  --include='*.ts' \
  --include='*.mjs' \
  | head -n 300 || true

printf '\n=== GOVERNANCE RUNTIME VALIDATION/GATE FUNCTIONS ===\n'
sed -n '820,1085p' db/governance-runtime.ts

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT DECISION ===\n'
echo "NEXT_ACTION=SELECT_EXISTING_REUSABLE_ELIGIBILITY_AND_READ_SEAMS_IF_PRESENT"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"
echo "DO_NOT_CREATE_NEW_READER_UNTIL_EXISTING_READ_PRIMITIVES_ARE_EXCLUDED=YES"

printf '\nENVELOPE_GATE_NEW_HYPOTHESIS_CLASSIFICATION=COMPLETE\n'
