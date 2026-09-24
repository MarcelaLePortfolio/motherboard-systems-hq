#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="836a4ae1b"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' BOUNDED ENVELOPE CREATION — TARGET CLASSIFICATION\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"
echo "LIVE_ENVELOPE_CREATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"

printf '\n=== EXISTING ENVELOPE CONSUMER ===\n'
for f in \
  server/envelope/production-envelope-consumer.ts \
  server/envelope/production-envelope-consumer.test.ts
do
  if [ -f "$f" ]; then
    printf '\n--- %s ---\n' "$f"
    sed -n '1,460p' "$f"
  else
    echo "ABSENT=$f"
  fi
done

printf '\n=== EXISTING ENVELOPE ROUTE ===\n'
sed -n '1,420p' server/routes/governance-envelope-route.ts
sed -n '1,460p' server/routes/governance-envelope-route.test.ts

printf '\n=== EXISTING ENVELOPE ENTRY POINT ===\n'
sed -n '1,420p' server/envelope/production-envelope-entry-point.ts
sed -n '1,420p' server/envelope/production-envelope-entry-point.test.ts

printf '\n=== EXACT ENVELOPE GATE READ CANDIDATES ===\n'
grep -RniE \
  'governance_envelope_gates|load.*envelope.*gate|envelope_gate_id.*validation_result_id|gate_status' \
  db server \
  --include='*.ts' \
  --include='*.mjs' \
  | head -n 520 || true

printf '\n=== EXACT VALIDATION READ PRIMITIVE ===\n'
sed -n '1,320p' db/governance-envelope-gate-validation-read-repository.ts
sed -n '1,360p' db/governance-envelope-gate-validation-read-repository.test.ts

printf '\n=== ENVELOPE GATE PERSISTENCE SHAPE ===\n'
grep -n -A90 -B25 \
  'CREATE TABLE IF NOT EXISTS governance_envelope_gates' \
  db/governance-runtime.ts || true

grep -n -A100 -B30 \
  'INSERT INTO governance_envelope_gates' \
  db/governance-runtime.ts || true

printf '\n=== ENVELOPE PERSISTENCE SHAPE ===\n'
grep -n -A110 -B30 \
  'CREATE TABLE IF NOT EXISTS governance_envelopes' \
  db/governance-runtime.ts || true

grep -n -A120 -B30 \
  'INSERT INTO governance_envelopes' \
  db/governance-runtime.ts || true

printf '\n=== REQUIRED CAPABILITIES AUTHORITATIVE SOURCES ===\n'
grep -RniE \
  'required_capabilities' \
  db server client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  | head -n 420 || true

printf '\n=== OPERATIONAL CORRIDOR AUTHORITATIVE SOURCES ===\n'
grep -RniE \
  'operational_corridor' \
  db server client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  | head -n 420 || true

printf '\n=== CLIENT PACKAGE FIELDS AVAILABLE FOR DERIVATION ===\n'
grep -nE \
  'type .*Canonical|interface .*Canonical|required_capabilities|operational_corridor|approved_work|approved_scope|approved_constraints|approved_artifacts|package_id|package_version' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  | head -n 320 || true

printf '\n=== CURRENT GATE CLIENT RESPONSE CONTRACT ===\n'
cat client/src/approvals/governanceEnvelopeGateApi.ts
cat client/src/approvals/governanceEnvelopeGateApi.test.ts

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
echo "Q1=DOES_ENVELOPE_CONSUMER_ALREADY_ENFORCE_ASSERT_ENVELOPE_CREATION_ELIGIBLE"
echo "Q2=DOES_ENVELOPE_CONSUMER_VERIFY_EXACT_GATE_VALIDATION_DELEGATION_PACKAGE_VERSION_LINEAGE"
echo "Q3=IS_THERE_AN_EXISTING_EXACT_READ_ONLY_ENVELOPE_GATE_READER"
echo "Q4=IF_NO_EXACT_GATE_READER_CAN_ONE_NARROW_READ_ONLY_PRIMITIVE_BE_EXTRACTED_WITHOUT_EXECUTION_AUTHORITY"
echo "Q5=DOES_GATE_ROUTE_RETURN_THE_PERSISTED_ENVELOPE_GATE_ID"
echo "Q6=CAN_CLIENT_RETAIN_THAT_EXACT_GATE_ID_INSTEAD_OF_RECONSTRUCTING_OR_LOOKING_UP_LATEST"
echo "Q7=DO_REQUIRED_CAPABILITIES_HAVE_AN_EXISTING_AUTHORITATIVE_SOURCE"
echo "Q8=DOES_OPERATIONAL_CORRIDOR_HAVE_AN_EXISTING_AUTHORITATIVE_SOURCE"
echo "Q9=IF_EITHER_FIELD_HAS_NO_AUTHORITATIVE_SOURCE_MUST_IMPLEMENTATION_STOP_BEFORE_INVENTING_SEMANTICS"

printf '\n=== REQUIRED TARGET-SET RULE ===\n'
echo "EXACT_GATE_LINEAGE_VERIFICATION_REQUIRED=YES"
echo "VALIDATION_PASSED_SEMANTIC_OWNER=db/governance-lifecycle-enforcement.ts"
echo "GATE_OPEN_SEMANTIC_OWNER=db/governance-lifecycle-enforcement.ts"
echo "DUPLICATE_LIFECYCLE_RULES=PROHIBITED"
echo "LATEST_GATE_LOOKUP=PROHIBITED"
echo "LATEST_VALIDATION_LOOKUP=PROHIBITED"
echo "DERIVED_LINEAGE_IDENTITY=PROHIBITED"
echo "INVENTED_REQUIRED_CAPABILITIES=PROHIBITED"
echo "INVENTED_OPERATIONAL_CORRIDOR=PROHIBITED"
echo "SPECULATIVE_TARGETS=PROHIBITED"

printf '\n=== PRESERVED AUTHORITY BOUNDARY ===\n'
echo "AUTOMATIC_GATE_TO_ENVELOPE_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIVE_ENVELOPE_CREATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_EXECUTION_TRANSITION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "NO_GENERIC_SHELL=YES"
echo "NO_SELF_AUTHORIZATION=YES"

printf '\n=== FAILURE CONTAINMENT ===\n'
echo "CURRENT_HYPOTHESIS_FAILED_ATTEMPTS=0"
echo "MAX_FAILED_ATTEMPTS_BEFORE_REVERT=3"
echo "IMPLEMENTATION_CHANGES_BY_THIS_SCRIPT=NONE"

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=FIX_EXACT_ATOMIC_TARGET_SET_OR_STOP_ON_UNRESOLVED_AUTHORITATIVE_INPUT"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"

printf '\nBOUNDED_ENVELOPE_CREATION_TARGET_CLASSIFICATION=COMPLETE\n'
