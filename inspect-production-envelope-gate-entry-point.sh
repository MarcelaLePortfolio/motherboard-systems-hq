#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="83f34ab30"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' PRODUCTION ENVELOPE GATE ENTRY POINT — EXACT CONTRACT INSPECTION\n'
printf '====================================================\n\n'

printf '\n=== CONSUMER ===\n'
sed -n '1,320p' server/gate/production-envelope-gate-consumer.ts

printf '\n=== ENTRY POINT ===\n'
sed -n '1,320p' server/gate/production-envelope-gate-entry-point.ts

printf '\n=== ROUTE ===\n'
sed -n '1,320p' server/routes/governance-envelope-gate-route.ts

printf '\n=== CONSUMER TEST ===\n'
sed -n '1,360p' server/gate/production-envelope-gate-consumer.test.ts

printf '\n=== ROUTE TEST ===\n'
sed -n '1,360p' server/routes/governance-envelope-gate-route.test.ts

printf '\n=== DB PERSISTENCE ===\n'
grep -RniE \
  'createGovernanceEnvelopeGate|governance_envelope_gates|envelope_gate_id|gate_status|gate_reason|gate_decision_timestamp' \
  db server/gate server/routes/governance-envelope-gate-route.ts \
  | head -n 320 || true

printf '\n=== AUTHORIZED EXACT LINEAGE ===\n'
echo "VALIDATION_RESULT_ID=ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
echo "DELEGATION_ID=8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
echo "PACKAGE_ID=pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
echo "PACKAGE_VERSION=1"
echo "AUTHORIZED_GATE_ATTEMPTS=1"
echo "GATE_ATTEMPT_CONSUMED=NO"

printf '\n=== INSPECTION BOUNDARY ===\n'
echo "LIVE_GATE_MUTATION=NO"
echo "DIRECT_DB_INSERT=NO"
echo "ENVELOPE_CREATION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nPRODUCTION_ENVELOPE_GATE_ENTRY_POINT_INSPECTION=COMPLETE\n'
