#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="f156e0d04"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' BOUNDED ENVELOPE CREATION — AUTHORITATIVE INPUT RESOLUTION\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"
echo "PRIOR_CLASSIFICATION=COMPLETE"
echo "LIVE_ENVELOPE_CREATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"

printf '\n=== PRODUCTION ENVELOPE CONSUMER ===\n'
sed -n '1,320p' server/envelope/production-envelope-consumer.ts

printf '\n=== PRODUCTION ENVELOPE ENTRY POINT ===\n'
sed -n '1,320p' server/envelope/production-envelope-entry-point.ts

printf '\n=== GOVERNANCE ENVELOPE ROUTE ===\n'
sed -n '1,320p' server/routes/governance-envelope-route.ts

printf '\n=== ENVELOPE GATE ROUTE + RESPONSE CONTRACT ===\n'
for f in \
  server/routes/governance-envelope-gate-route.ts \
  server/routes/governance-envelope-gate-route.test.ts
do
  printf '\n--- %s ---\n' "$f"
  sed -n '1,440p' "$f"
done

printf '\n=== EXACT ENVELOPE GATE READ IMPLEMENTATIONS ===\n'
grep -RniE \
  'FROM governance_envelope_gates|loadExact.*EnvelopeGate|load.*EnvelopeGate|envelope_gate_id' \
  db server \
  --include='*.ts' \
  --include='*.mjs' \
  | head -n 600 || true

printf '\n=== LIFECYCLE SEMANTICS OWNER ===\n'
sed -n '1,360p' db/governance-lifecycle-enforcement.ts

if [ -f db/governance-lifecycle-composition.ts ]; then
  printf '\n=== LIFECYCLE COMPOSITION ===\n'
  sed -n '1,420p' db/governance-lifecycle-composition.ts
fi

printf '\n=== MATILDA ENVELOPE RUNTIME ===\n'
sed -n '1,280p' db/matilda-envelope-runtime.ts

printf '\n=== CANONICAL PACKAGE CLIENT READ MODEL ===\n'
sed -n '1,380p' client/src/approvals/canonicalPackageReadApi.ts

printf '\n=== REQUIRED CAPABILITIES CANDIDATE SOURCES ===\n'
grep -RniE \
  'required_capabilities|capability_requirements' \
  db server client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  | head -n 700 || true

printf '\n=== OPERATIONAL CORRIDOR CANDIDATE SOURCES ===\n'
grep -RniE \
  'operational_corridor|operational_requirements' \
  db server client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  | head -n 700 || true

printf '\n=== GOVERNANCE PACKAGE AUTHORITATIVE FIELDS ===\n'
grep -n -A120 -B20 \
  'CREATE TABLE IF NOT EXISTS governance_packages' \
  db/governance-runtime.ts || true

printf '\n=== CLIENT GATE ACTION LINEAGE RETENTION ===\n'
grep -nE \
  'validationResultId|envelopeGate|gate_id|handleCreateEnvelopeGate|postGovernanceEnvelopeGate' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  | head -n 320 || true

printf '\n=== RESOLUTION RULES ===\n'
echo "EXACT_GATE_LINEAGE_VERIFICATION_REQUIRED=YES"
echo "VALIDATION_PASSED_SEMANTIC_OWNER=db/governance-lifecycle-enforcement.ts"
echo "GATE_OPEN_SEMANTIC_OWNER=db/governance-lifecycle-enforcement.ts"
echo "LATEST_GATE_LOOKUP=PROHIBITED"
echo "LATEST_VALIDATION_LOOKUP=PROHIBITED"
echo "DERIVED_LINEAGE_IDENTITY=PROHIBITED"
echo "INVENTED_REQUIRED_CAPABILITIES=PROHIBITED"
echo "INVENTED_OPERATIONAL_CORRIDOR=PROHIBITED"
echo "DUPLICATE_LIFECYCLE_RULES=PROHIBITED"

printf '\n=== STOP CONDITIONS ===\n'
echo "IF_REQUIRED_CAPABILITIES_HAS_NO_EXISTING_AUTHORITATIVE_SOURCE=STOP"
echo "IF_OPERATIONAL_CORRIDOR_HAS_NO_EXISTING_AUTHORITATIVE_SOURCE=STOP"
echo "IF_EXACT_GATE_LINEAGE_CANNOT_BE_VERIFIED_WITHOUT_INVENTED_SEMANTICS=STOP"
echo "IF_GATE_RESPONSE_DOES_NOT_SUPPORT_EXACT_ID_RETENTION=STOP_AND_RECLASSIFY"
echo "IF_ALL_REQUIRED_INPUTS_ARE_AUTHORITATIVE=FIX_ATOMIC_TARGET_SET_BEFORE_IMPLEMENTATION"

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
echo "NEXT_ACTION=DETERMINE_IF_AUTHORITATIVE_INPUTS_ARE_FULLY_RESOLVED"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"

printf '\nBOUNDED_ENVELOPE_CREATION_AUTHORITATIVE_INPUT_RESOLUTION=COMPLETE\n'
