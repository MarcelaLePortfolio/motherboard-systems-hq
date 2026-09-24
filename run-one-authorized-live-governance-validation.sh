#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6ddc9922f"
DB="db/main.db"

DELEGATION_ID="8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
PACKAGE_ID="pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
PACKAGE_VERSION="1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

cat > scripts/run-one-authorized-live-governance-validation.ts << 'TS'
import crypto from "node:crypto";

import {
  consumeProductionValidationEntryPoint,
} from "../server/validation/production-validation-consumer";

const delegation_id = "8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c";
const package_id = "pkg-68dfc4bc-791d-4156-b32a-e51e458b3160";
const package_version = 1;

const validation_result_id = crypto.randomUUID();

const result = consumeProductionValidationEntryPoint({
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status: "VALIDATION_PASSED",
  governance_findings:
    "Exact authorized Delegation verified; no governance blocker identified for bounded Envelope eligibility validation.",
  operational_requirements:
    "Preserve exact governed lineage; require explicit operator Envelope Gate and explicit operator Envelope creation; no automatic progression.",
  capability_requirements:
    "Governed Envelope creation eligibility validation only.",
  escalations: null,
  validation_timestamp: new Date().toISOString(),
});

console.log(JSON.stringify(result, null, 2));

if (!result.ok) {
  process.exit(21);
}

console.log(`LIVE_VALIDATION_RESULT_ID=${validation_result_id}`);
TS

printf '\n====================================================\n'
printf ' ONE AUTHORIZED LIVE GOVERNANCE VALIDATION\n'
printf '====================================================\n\n'

BEFORE_VALIDATIONS="$(
  sqlite3 "$DB" \
    "SELECT COUNT(*) FROM governance_validation_results WHERE delegation_id='$DELEGATION_ID' AND package_id='$PACKAGE_ID' AND package_version=$PACKAGE_VERSION;"
)"
BEFORE_GATES="$(sqlite3 "$DB" "SELECT COUNT(*) FROM governance_envelope_gates;")"
BEFORE_ENVELOPES="$(sqlite3 "$DB" "SELECT COUNT(*) FROM governance_envelopes;")"

echo "BEFORE_EXACT_VALIDATION_COUNT=$BEFORE_VALIDATIONS"
echo "BEFORE_GATE_COUNT=$BEFORE_GATES"
echo "BEFORE_ENVELOPE_COUNT=$BEFORE_ENVELOPES"

test "$BEFORE_VALIDATIONS" = "0"

set +e
VALIDATION_OUTPUT="$(npx tsx scripts/run-one-authorized-live-governance-validation.ts 2>&1)"
STATUS=$?
set -e

printf '%s\n' "$VALIDATION_OUTPUT"

if [ "$STATUS" -ne 0 ]; then
  echo "LIVE_GOVERNANCE_VALIDATION=FAILED_CLOSED"
  echo "AUTHORIZED_LIVE_VALIDATION_ATTEMPT_CONSUMED=YES"
  echo "SECOND_ATTEMPT_WITHOUT_NEW_AUTHORIZATION=PROHIBITED"
  exit "$STATUS"
fi

VALIDATION_RESULT_ID="$(
  printf '%s\n' "$VALIDATION_OUTPUT" \
    | sed -n 's/^LIVE_VALIDATION_RESULT_ID=//p' \
    | tail -n 1
)"

test -n "$VALIDATION_RESULT_ID"

AFTER_VALIDATIONS="$(
  sqlite3 "$DB" \
    "SELECT COUNT(*) FROM governance_validation_results WHERE delegation_id='$DELEGATION_ID' AND package_id='$PACKAGE_ID' AND package_version=$PACKAGE_VERSION;"
)"
AFTER_GATES="$(sqlite3 "$DB" "SELECT COUNT(*) FROM governance_envelope_gates;")"
AFTER_ENVELOPES="$(sqlite3 "$DB" "SELECT COUNT(*) FROM governance_envelopes;")"

test "$AFTER_VALIDATIONS" = "1"
test "$AFTER_GATES" = "$BEFORE_GATES"
test "$AFTER_ENVELOPES" = "$BEFORE_ENVELOPES"

sqlite3 -header -column "$DB" "
SELECT
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status,
  governance_findings,
  operational_requirements,
  capability_requirements,
  escalations,
  validation_timestamp
FROM governance_validation_results
WHERE validation_result_id = '$VALIDATION_RESULT_ID';
"

printf '\n=== RESULT ===\n'
echo "LIVE_GOVERNANCE_VALIDATION=PASS"
echo "AUTHORIZED_LIVE_VALIDATION_ATTEMPT_CONSUMED=YES"
echo "VALIDATION_RESULT_ID=$VALIDATION_RESULT_ID"
echo "VALIDATION_STATUS=VALIDATION_PASSED"
echo "EXACT_VALIDATION_COUNT_AFTER=1"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "GATE_COUNT_UNCHANGED=YES"
echo "ENVELOPE_COUNT_UNCHANGED=YES"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "SECOND_LIVE_VALIDATION_WITHOUT_NEW_AUTHORIZATION=PROHIBITED"
echo "ENVELOPE_GATE_CREATION_AUTHORIZED_BY_THIS_ACTION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "AUTOMATIC_ADVANCE=NO"
