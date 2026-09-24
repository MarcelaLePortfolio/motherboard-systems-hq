#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e00e2f84d"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' BOUNDED ENVELOPE CREATION — RUNTIME INSPECTION\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_ENVELOPE_CREATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"

printf '\n=== ENVELOPE ROUTE FILES ===\n'
find server db client/src -type f \
  \( -iname '*envelope*' -o -iname '*lifecycle*' \) \
  | sort

printf '\n=== CURRENT ENVELOPE ROUTE REFERENCES ===\n'
grep -RniE \
  '/api/governance/envelope|createGovernanceEnvelope|governance_envelope|envelope_gate_id|required_capabilities|operational_corridor' \
  server db client/src \
  --include='*.ts' \
  --include='*.tsx' \
  | head -n 420 || true

printf '\n=== PRODUCTION ENVELOPE ROUTE ===\n'
if [ -f server/routes/governance-envelope-route.ts ]; then
  sed -n '1,360p' server/routes/governance-envelope-route.ts
fi

printf '\n=== PRODUCTION ENVELOPE CONSUMER ===\n'
if [ -f server/envelope/production-envelope-consumer.ts ]; then
  sed -n '1,360p' server/envelope/production-envelope-consumer.ts
fi

printf '\n=== PRODUCTION ENVELOPE ENTRY POINT ===\n'
if [ -f server/envelope/production-envelope-entry-point.ts ]; then
  sed -n '1,360p' server/envelope/production-envelope-entry-point.ts
fi

printf '\n=== ENVELOPE TESTS ===\n'
for f in \
  server/envelope/production-envelope-consumer.test.ts \
  server/envelope/production-envelope-entry-point.test.ts \
  server/routes/governance-envelope-route.test.ts
do
  if [ -f "$f" ]; then
    printf '\n--- %s ---\n' "$f"
    sed -n '1,420p' "$f"
  fi
done

printf '\n=== LIFECYCLE ELIGIBILITY CONTRACT ===\n'
sed -n '1,420p' db/governance-lifecycle-enforcement.ts

printf '\n=== EXECUTION READ ENVELOPE LINEAGE ===\n'
grep -nE \
  'envelope_id|envelope_gate_id|validation_result_id|delegation_id|package_id|package_version|governance_envelopes|governance_envelope_gates' \
  db/governance-execution-read-repository.ts \
  | head -n 320 || true

printf '\n=== ENVELOPE PERSISTENCE SCHEMA/RUNTIME ===\n'
grep -RniE \
  'CREATE TABLE.*governance_envelopes|INSERT INTO governance_envelopes|governance_envelopes' \
  db server \
  --include='*.ts' \
  --include='*.mjs' \
  --include='*.sql' \
  | head -n 320 || true

printf '\n=== CURRENT CLIENT ENVELOPE REFERENCES ===\n'
grep -RniE \
  '/api/governance/envelope|Envelope creation|Create Envelope|envelope_id|envelope_gate_id' \
  client/src \
  --include='*.ts' \
  --include='*.tsx' \
  | head -n 320 || true

printf '\n=== CURRENT ENVELOPE GATE UI HANDOFF ===\n'
sed -n '680,1020p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== DESIGN QUESTIONS ===\n'
echo "Q1=DOES_EXISTING_ENVELOPE_ROUTE_ALREADY_ENFORCE_EXACT_GATE_VALIDATION_DELEGATION_PACKAGE_LINEAGE"
echo "Q2=DOES_EXISTING_ENVELOPE_CONSUMER_CALL_ASSERT_ENVELOPE_CREATION_ELIGIBLE_BEFORE_PERSISTENCE"
echo "Q3=WHAT_EXACT_FIELDS_DOES_ENVELOPE_ROUTE_REQUIRE"
echo "Q4=IS_REQUIRED_CAPABILITIES_AND_OPERATIONAL_CORRIDOR_OPERATOR_INPUT_OR_DERIVED_EXISTING_DATA"
echo "Q5=CAN_CLIENT_RETAIN_SUCCESSFUL_GATE_ID_AND_EXPOSE_A_SEPARATE_MANUAL_ENVELOPE_ACTION"
echo "Q6=WHAT_MINIMUM_FILES_ARE_REQUIRED_WITHOUT_SERVER_AUTHORITY_EXPANSION"

printf '\n=== NONNEGOTIABLE BOUNDARY ===\n'
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

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=CLASSIFY_MINIMUM_BOUNDED_ENVELOPE_CREATION_TARGET_SET"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"

printf '\nBOUNDED_ENVELOPE_CREATION_RUNTIME_INSPECTION=COMPLETE\n'
