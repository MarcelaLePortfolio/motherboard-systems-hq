#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="2851afa47"
DB="db/main.db"

VALIDATION_RESULT_ID="ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
DELEGATION_ID="8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
PACKAGE_ID="pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
PACKAGE_VERSION="1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

printf '\n====================================================\n'
printf ' ONE AUTHORIZED LIVE ENVELOPE GATE — PREFLIGHT\n'
printf '====================================================\n\n'

VALIDATION_COUNT="$(
  sqlite3 "$DB" "
    SELECT COUNT(*)
    FROM governance_validation_results
    WHERE validation_result_id='$VALIDATION_RESULT_ID'
      AND delegation_id='$DELEGATION_ID'
      AND package_id='$PACKAGE_ID'
      AND package_version=$PACKAGE_VERSION
      AND validation_status='VALIDATION_PASSED';
  "
)"

GATE_COUNT="$(
  sqlite3 "$DB" "
    SELECT COUNT(*)
    FROM governance_envelope_gates
    WHERE validation_result_id='$VALIDATION_RESULT_ID'
      AND delegation_id='$DELEGATION_ID'
      AND package_id='$PACKAGE_ID'
      AND package_version=$PACKAGE_VERSION;
  "
)"

ENVELOPE_COUNT="$(
  sqlite3 "$DB" "
    SELECT COUNT(*)
    FROM governance_envelopes
    WHERE validation_result_id='$VALIDATION_RESULT_ID'
      AND delegation_id='$DELEGATION_ID'
      AND package_id='$PACKAGE_ID'
      AND package_version=$PACKAGE_VERSION;
  "
)"

echo "EXACT_PASSED_VALIDATION_COUNT=$VALIDATION_COUNT"
echo "EXACT_GATE_COUNT_BEFORE=$GATE_COUNT"
echo "EXACT_ENVELOPE_COUNT_BEFORE=$ENVELOPE_COUNT"

test "$VALIDATION_COUNT" = "1"
test "$GATE_COUNT" = "0"
test "$ENVELOPE_COUNT" = "0"

printf '\n=== AUTHORIZED EFFECT ===\n'
echo "ONE_LIVE_ENVELOPE_GATE_CREATION=AUTHORIZED"
echo "VALIDATION_RESULT_ID=$VALIDATION_RESULT_ID"
echo "DELEGATION_ID=$DELEGATION_ID"
echo "PACKAGE_ID=$PACKAGE_ID"
echo "PACKAGE_VERSION=$PACKAGE_VERSION"

printf '\n=== STOP CONDITION ===\n'
echo "EXACT_VALIDATION_LINEAGE=VERIFIED"
echo "VALIDATION_STATUS=VALIDATION_PASSED"
echo "EXISTING_EXACT_GATE=NO"
echo "EXISTING_EXACT_ENVELOPE=NO"
echo "MUTATION_NOT_EXECUTED_BY_THIS_PREFLIGHT=YES"
echo "NEXT_ACTION=INVOKE_EXISTING_PRODUCTION_ENVELOPE_GATE_ENTRY_POINT_ONLY"
echo "DO_NOT_DIRECTLY_INSERT_DATABASE_ROW=YES"
echo "DO_NOT_INVENT_GATE_CONSUMER_SIGNATURE=YES"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "SECOND_GATE_ATTEMPT_WITHOUT_NEW_AUTHORIZATION=PROHIBITED"

printf '\nONE_AUTHORIZED_LIVE_ENVELOPE_GATE_PREFLIGHT=PASS\n'
