#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="423c40df1"
DB="db/main.db"

VALIDATION_RESULT_ID="ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
ENVELOPE_GATE_ID="gate-live-envelope-validation-20260924T060547Z"
DELEGATION_ID="8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
PACKAGE_ID="pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
PACKAGE_VERSION="1"
ENVELOPE_ID="envelope-live-validation-$(date -u +%Y%m%dT%H%M%SZ)"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

EXACT_ELIGIBLE_COUNT="$(
  sqlite3 "$DB" "
    SELECT COUNT(*)
    FROM governance_delegations d
    JOIN governance_validation_results v
      ON v.delegation_id = d.delegation_id
     AND v.package_id = d.package_id
     AND v.package_version = d.package_version
    JOIN governance_envelope_gates g
      ON g.validation_result_id = v.validation_result_id
     AND g.delegation_id = d.delegation_id
     AND g.package_id = d.package_id
     AND g.package_version = d.package_version
    WHERE d.delegation_id = '$DELEGATION_ID'
      AND d.package_id = '$PACKAGE_ID'
      AND d.package_version = $PACKAGE_VERSION
      AND d.authorization_state = 'AUTHORIZED'
      AND v.validation_result_id = '$VALIDATION_RESULT_ID'
      AND v.validation_status = 'VALIDATION_PASSED'
      AND TRIM(COALESCE(v.operational_requirements, '')) <> ''
      AND TRIM(COALESCE(v.capability_requirements, '')) <> ''
      AND g.envelope_gate_id = '$ENVELOPE_GATE_ID'
      AND g.gate_status = 'OPEN';
  "
)"

ENVELOPE_COUNT_BEFORE="$(
  sqlite3 "$DB" "
    SELECT COUNT(*)
    FROM governance_envelopes
    WHERE package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION
      AND delegation_id = '$DELEGATION_ID'
      AND validation_result_id = '$VALIDATION_RESULT_ID'
      AND envelope_gate_id = '$ENVELOPE_GATE_ID';
  "
)"

test "$EXACT_ELIGIBLE_COUNT" = "1"
test "$ENVELOPE_COUNT_BEFORE" = "0"

cat > scripts/run-one-authorized-live-envelope-creation.ts << TS
import { consumeProductionEnvelopeEntryPoint } from "../server/envelope/production-envelope-consumer";

const result = consumeProductionEnvelopeEntryPoint({
  envelope_id: "$ENVELOPE_ID",
  package_id: "$PACKAGE_ID",
  package_version: $PACKAGE_VERSION,
  delegation_id: "$DELEGATION_ID",
  validation_result_id: "$VALIDATION_RESULT_ID",
  envelope_gate_id: "$ENVELOPE_GATE_ID",
  lifecycle_state: "ENVELOPE_CREATED",
});

console.log(JSON.stringify(result, null, 2));

if (!result.ok) {
  process.exitCode = 1;
}
TS

printf '\n====================================================\n'
printf ' ONE AUTHORIZED LIVE ENVELOPE CREATION\n'
printf '====================================================\n\n'

echo "ENVELOPE_ID=$ENVELOPE_ID"
echo "PACKAGE_ID=$PACKAGE_ID"
echo "PACKAGE_VERSION=$PACKAGE_VERSION"
echo "DELEGATION_ID=$DELEGATION_ID"
echo "VALIDATION_RESULT_ID=$VALIDATION_RESULT_ID"
echo "ENVELOPE_GATE_ID=$ENVELOPE_GATE_ID"
echo "EXACT_ELIGIBLE_LINEAGE_COUNT=$EXACT_ELIGIBLE_COUNT"
echo "EXACT_ENVELOPE_COUNT_BEFORE=$ENVELOPE_COUNT_BEFORE"

./node_modules/.bin/tsx scripts/run-one-authorized-live-envelope-creation.ts

ENVELOPE_COUNT_AFTER="$(
  sqlite3 "$DB" "
    SELECT COUNT(*)
    FROM governance_envelopes
    WHERE envelope_id = '$ENVELOPE_ID'
      AND package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION
      AND delegation_id = '$DELEGATION_ID'
      AND validation_result_id = '$VALIDATION_RESULT_ID'
      AND envelope_gate_id = '$ENVELOPE_GATE_ID';
  "
)"

test "$ENVELOPE_COUNT_AFTER" = "1"

sqlite3 -header -column "$DB" "
SELECT
  envelope_id,
  package_id,
  package_version,
  delegation_id,
  validation_result_id,
  envelope_gate_id,
  validation_status,
  required_capabilities,
  operational_corridor,
  lifecycle_state,
  created_at
FROM governance_envelopes
WHERE envelope_id = '$ENVELOPE_ID';
"

VALIDATION_CAPABILITIES="$(
  sqlite3 "$DB" "
    SELECT TRIM(capability_requirements)
    FROM governance_validation_results
    WHERE validation_result_id = '$VALIDATION_RESULT_ID';
  "
)"

VALIDATION_OPERATIONAL="$(
  sqlite3 "$DB" "
    SELECT TRIM(operational_requirements)
    FROM governance_validation_results
    WHERE validation_result_id = '$VALIDATION_RESULT_ID';
  "
)"

ENVELOPE_CAPABILITIES="$(
  sqlite3 "$DB" "
    SELECT required_capabilities
    FROM governance_envelopes
    WHERE envelope_id = '$ENVELOPE_ID';
  "
)"

ENVELOPE_OPERATIONAL="$(
  sqlite3 "$DB" "
    SELECT operational_corridor
    FROM governance_envelopes
    WHERE envelope_id = '$ENVELOPE_ID';
  "
)"

test "$ENVELOPE_CAPABILITIES" = "$VALIDATION_CAPABILITIES"
test "$ENVELOPE_OPERATIONAL" = "$VALIDATION_OPERATIONAL"

printf '\n=== RESULT ===\n'
echo "LIVE_ENVELOPE_CREATION=PASS"
echo "AUTHORIZED_LIVE_ENVELOPE_ATTEMPT_CONSUMED=YES"
echo "ENVELOPE_ID=$ENVELOPE_ID"
echo "EXACT_ENVELOPE_COUNT_AFTER=$ENVELOPE_COUNT_AFTER"
echo "AUTHORITATIVE_CAPABILITY_SEMANTICS_MATCH=YES"
echo "AUTHORITATIVE_OPERATIONAL_SEMANTICS_MATCH=YES"
echo "CALLER_SEMANTIC_AUTHORITY=NO"

printf '\n=== PRESERVED AUTHORITY BOUNDARY ===\n'
echo "AUTOMATIC_GATE_TO_ENVELOPE_TRANSITION=NO"
echo "SECOND_ENVELOPE_CREATION_WITHOUT_NEW_AUTHORIZATION=PROHIBITED"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nLIVE_ENVELOPE_CREATION_VALIDATION=PASS\n'
