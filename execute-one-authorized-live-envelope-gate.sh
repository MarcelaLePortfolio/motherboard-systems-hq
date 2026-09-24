#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="15227b729"

VALIDATION_RESULT_ID="ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
DELEGATION_ID="8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
PACKAGE_ID="pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
PACKAGE_VERSION="1"
ENVELOPE_GATE_ID="gate-live-envelope-validation-$(date -u +%Y%m%dT%H%M%SZ)"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

VALIDATION_COUNT="$(
  sqlite3 db/main.db "
    SELECT COUNT(*)
    FROM governance_validation_results
    WHERE validation_result_id = '$VALIDATION_RESULT_ID'
      AND delegation_id = '$DELEGATION_ID'
      AND package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION
      AND validation_status = 'VALIDATION_PASSED';
  "
)"

GATE_COUNT_BEFORE="$(
  sqlite3 db/main.db "
    SELECT COUNT(*)
    FROM governance_envelope_gates
    WHERE validation_result_id = '$VALIDATION_RESULT_ID'
      AND delegation_id = '$DELEGATION_ID'
      AND package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION;
  "
)"

ENVELOPE_COUNT_BEFORE="$(
  sqlite3 db/main.db "
    SELECT COUNT(*)
    FROM governance_envelopes
    WHERE validation_result_id = '$VALIDATION_RESULT_ID'
      AND delegation_id = '$DELEGATION_ID'
      AND package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION;
  "
)"

test "$VALIDATION_COUNT" = "1"
test "$GATE_COUNT_BEFORE" = "0"
test "$ENVELOPE_COUNT_BEFORE" = "0"

cat > scripts/run-one-authorized-live-envelope-gate.ts << TS
import { consumeProductionEnvelopeGateEntryPoint } from "../server/gate/production-envelope-gate-consumer";

const result = consumeProductionEnvelopeGateEntryPoint({
  envelope_gate_id: "$ENVELOPE_GATE_ID",
  package_id: "$PACKAGE_ID",
  package_version: $PACKAGE_VERSION,
  delegation_id: "$DELEGATION_ID",
  validation_result_id: "$VALIDATION_RESULT_ID",
  gate_status: "OPEN",
  gate_reason:
    "Exact authorized Governance Validation passed; explicit operator authorized one live Envelope Gate creation.",
});

console.log(JSON.stringify(result, null, 2));

if (!result.ok) {
  process.exitCode = 1;
}
TS

printf '\n====================================================\n'
printf ' ONE AUTHORIZED LIVE ENVELOPE GATE CREATION\n'
printf '====================================================\n\n'

echo "VALIDATION_RESULT_ID=$VALIDATION_RESULT_ID"
echo "ENVELOPE_GATE_ID=$ENVELOPE_GATE_ID"
echo "EXACT_GATE_COUNT_BEFORE=$GATE_COUNT_BEFORE"
echo "EXACT_ENVELOPE_COUNT_BEFORE=$ENVELOPE_COUNT_BEFORE"

./node_modules/.bin/tsx scripts/run-one-authorized-live-envelope-gate.ts

GATE_COUNT_AFTER="$(
  sqlite3 db/main.db "
    SELECT COUNT(*)
    FROM governance_envelope_gates
    WHERE envelope_gate_id = '$ENVELOPE_GATE_ID'
      AND validation_result_id = '$VALIDATION_RESULT_ID'
      AND delegation_id = '$DELEGATION_ID'
      AND package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION
      AND gate_status = 'OPEN';
  "
)"

ENVELOPE_COUNT_AFTER="$(
  sqlite3 db/main.db "
    SELECT COUNT(*)
    FROM governance_envelopes
    WHERE validation_result_id = '$VALIDATION_RESULT_ID'
      AND delegation_id = '$DELEGATION_ID'
      AND package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION;
  "
)"

test "$GATE_COUNT_AFTER" = "1"
test "$ENVELOPE_COUNT_AFTER" = "$ENVELOPE_COUNT_BEFORE"

sqlite3 -header -column db/main.db "
SELECT
  envelope_gate_id,
  package_id,
  package_version,
  delegation_id,
  validation_result_id,
  gate_status,
  gate_reason,
  gate_decision_timestamp,
  created_at
FROM governance_envelope_gates
WHERE envelope_gate_id = '$ENVELOPE_GATE_ID';
"

printf '\n=== RESULT ===\n'
echo "LIVE_ENVELOPE_GATE_CREATION=PASS"
echo "AUTHORIZED_GATE_ATTEMPT_CONSUMED=YES"
echo "ENVELOPE_GATE_ID=$ENVELOPE_GATE_ID"
echo "GATE_STATUS=OPEN"
echo "EXACT_GATE_COUNT_AFTER=$GATE_COUNT_AFTER"
echo "ENVELOPE_COUNT_UNCHANGED=YES"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "SECOND_GATE_ATTEMPT_WITHOUT_NEW_AUTHORIZATION=PROHIBITED"
echo "ENVELOPE_CREATION_AUTHORIZED_BY_GATE_ACTION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "AUTOMATIC_ADVANCE=NO"

git diff --check -- scripts/run-one-authorized-live-envelope-gate.ts

git add -- \
  execute-one-authorized-live-envelope-gate.sh \
  scripts/run-one-authorized-live-envelope-gate.ts

git commit -m "Run one authorized live Envelope Gate creation"
git push origin "$BRANCH"
