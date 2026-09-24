#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="dfa0bf624"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' BOUNDED ENVELOPE CREATION — FOUR UNRESOLVED SEAMS\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"
echo "IMPLEMENTATION_MAY_BEGIN=NO"
echo "INSPECTION_SCOPE=FOUR_UNRESOLVED_SEAMS_ONLY"

printf '\n=== SEAM 1: CAPABILITY REQUIREMENTS → REQUIRED CAPABILITIES ===\n'
grep -RniE \
  'capability_requirements.*required_capabilities|required_capabilities.*capability_requirements' \
  db server client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' || true

printf '\n=== SEAM 2: OPERATIONAL REQUIREMENTS → OPERATIONAL CORRIDOR ===\n'
grep -RniE \
  'operational_requirements.*operational_corridor|operational_corridor.*operational_requirements' \
  db server client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' || true

printf '\n=== SEAM 3: EXACT ENVELOPE GATE ID RETURN / RETENTION ===\n'
sed -n '1,360p' server/routes/governance-envelope-gate-route.ts
sed -n '1,320p' server/gate/production-envelope-gate-consumer.ts
sed -n '1,280p' server/gate/production-envelope-gate-entry-point.ts
sed -n '1,220p' client/src/approvals/governanceEnvelopeGateApi.ts

printf '\n=== SEAM 4: EXACT READ-ONLY GATE PRIMITIVE ===\n'
grep -RniE \
  'FROM governance_envelope_gates|loadExact.*Gate|load.*EnvelopeGate|GovernanceEnvelopeGate.*Loader' \
  db server \
  --include='*.ts' \
  --include='*.mjs' \
  | head -n 500 || true

printf '\n=== EXECUTION READER EXACT GATE QUERY ===\n'
sed -n '132,190p' db/governance-execution-read-repository.ts

printf '\n=== VALIDATION RESULT FIELDS AVAILABLE UPSTREAM ===\n'
sed -n '1,220p' db/governance-envelope-gate-validation-read-repository.ts

printf '\n=== DECISION RULES ===\n'
echo "IF_EXPLICIT_MAPPING_EXISTS=REUSE_EXISTING_MAPPING_ONLY"
echo "IF_NO_EXPLICIT_MAPPING_EXISTS=AUTHORITATIVE_INPUT_REMAINS_UNRESOLVED"
echo "IF_GATE_ROUTE_RETURNS_PERSISTED_GATE_ID=CLIENT_MAY_RETAIN_EXACT_RETURNED_ID"
echo "IF_GATE_ID_IS_PREGENERATED_AND_PERSISTED_UNCHANGED=CLIENT_MAY_RETAIN_THAT_EXACT_PREGENERATED_ID_AFTER_SUCCESS"
echo "IF_EXACT_GATE_READER_EXISTS=REUSE_IT"
echo "IF_ONLY_EXECUTION_CHAIN_QUERY_EXISTS=DO_NOT_REUSE_CHAIN_LOADER_IF_IT_REQUIRES_FUTURE_ENVELOPE"
echo "IF_NO_NARROW_GATE_READER_EXISTS=CLASSIFY_NEED_FOR_NARROW_READ_ONLY_PRIMITIVE"
echo "LATEST_GATE_LOOKUP=PROHIBITED"
echo "LATEST_VALIDATION_LOOKUP=PROHIBITED"
echo "INVENTED_CAPABILITY_MAPPING=PROHIBITED"
echo "INVENTED_CORRIDOR_MAPPING=PROHIBITED"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "LIVE_ENVELOPE_CREATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_GATE_TO_ENVELOPE_TRANSITION=NO"
echo "AUTOMATIC_EXECUTION_TRANSITION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=CLASSIFY_FOUR_SEAM_RESULTS_AND_EITHER_FIX_ATOMIC_TARGET_SET_OR_STOP"
echo "IMPLEMENTATION_ATTEMPT=NOT_STARTED"

printf '\nFOUR_UNRESOLVED_ENVELOPE_CREATION_SEAMS_INSPECTION=COMPLETE\n'
