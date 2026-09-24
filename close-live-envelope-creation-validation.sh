#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="776fdcddb"
DB="db/main.db"

DELEGATION_ID="8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
PACKAGE_ID="pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
PACKAGE_VERSION="1"
VALIDATION_RESULT_ID="ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
ENVELOPE_GATE_ID="gate-live-envelope-validation-20260924T060547Z"
ENVELOPE_ID="envelope-live-validation-20260924T060723Z"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

mkdir -p docs/checkpoints

DELEGATION_COUNT="$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM governance_delegations
WHERE delegation_id='$DELEGATION_ID'
  AND package_id='$PACKAGE_ID'
  AND package_version=$PACKAGE_VERSION
  AND authorization_state='AUTHORIZED';
")"

VALIDATION_COUNT="$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM governance_validation_results
WHERE validation_result_id='$VALIDATION_RESULT_ID'
  AND delegation_id='$DELEGATION_ID'
  AND package_id='$PACKAGE_ID'
  AND package_version=$PACKAGE_VERSION
  AND validation_status='VALIDATION_PASSED';
")"

GATE_COUNT="$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM governance_envelope_gates
WHERE envelope_gate_id='$ENVELOPE_GATE_ID'
  AND validation_result_id='$VALIDATION_RESULT_ID'
  AND delegation_id='$DELEGATION_ID'
  AND package_id='$PACKAGE_ID'
  AND package_version=$PACKAGE_VERSION
  AND gate_status='OPEN';
")"

ENVELOPE_COUNT="$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM governance_envelopes
WHERE envelope_id='$ENVELOPE_ID'
  AND envelope_gate_id='$ENVELOPE_GATE_ID'
  AND validation_result_id='$VALIDATION_RESULT_ID'
  AND delegation_id='$DELEGATION_ID'
  AND package_id='$PACKAGE_ID'
  AND package_version=$PACKAGE_VERSION
  AND validation_status='VALIDATION_PASSED'
  AND lifecycle_state='ENVELOPE_CREATED';
")"

test "$DELEGATION_COUNT" = "1"
test "$VALIDATION_COUNT" = "1"
test "$GATE_COUNT" = "1"
test "$ENVELOPE_COUNT" = "1"

VALIDATION_CAPABILITIES="$(sqlite3 "$DB" "
SELECT TRIM(capability_requirements)
FROM governance_validation_results
WHERE validation_result_id='$VALIDATION_RESULT_ID';
")"

VALIDATION_OPERATIONAL="$(sqlite3 "$DB" "
SELECT TRIM(operational_requirements)
FROM governance_validation_results
WHERE validation_result_id='$VALIDATION_RESULT_ID';
")"

ENVELOPE_CAPABILITIES="$(sqlite3 "$DB" "
SELECT required_capabilities
FROM governance_envelopes
WHERE envelope_id='$ENVELOPE_ID';
")"

ENVELOPE_OPERATIONAL="$(sqlite3 "$DB" "
SELECT operational_corridor
FROM governance_envelopes
WHERE envelope_id='$ENVELOPE_ID';
")"

test "$VALIDATION_CAPABILITIES" = "$ENVELOPE_CAPABILITIES"
test "$VALIDATION_OPERATIONAL" = "$ENVELOPE_OPERATIONAL"

cat > docs/checkpoints/LIVE_ENVELOPE_CREATION_VALIDATION_CLOSURE.md << 'DOC'
# Live Envelope Creation Validation Closure

Status: CLOSED

## Exact governed lineage

- Package: `pkg-68dfc4bc-791d-4156-b32a-e51e458b3160`
- Package version: `1`
- Delegation: `8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c`
- Validation Result: `ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a`
- Envelope Gate: `gate-live-envelope-validation-20260924T060547Z`
- Envelope: `envelope-live-validation-20260924T060723Z`

## Verified outcome

The exact authorized Delegation was consumed by one explicitly authorized live Governance Validation.

The Validation persisted as `VALIDATION_PASSED` with authoritative operational and capability semantics.

One separately authorized live Envelope Gate was created for the exact Validation lineage and persisted as `OPEN`.

One authorized live Envelope creation was executed for that exact Delegation, Validation, and Gate lineage.

The resulting Envelope persisted with lifecycle state `ENVELOPE_CREATED`.

The Envelope's required capabilities exactly matched the persisted Validation capability requirements.

The Envelope's operational corridor exactly matched the persisted Validation operational requirements.

Caller-provided semantic authority was not used.

## Preserved authority boundary

No automatic Gate-to-Envelope transition occurred.

No lifecycle transition, routing, assignment, scheduling, worker claim, orchestration, execution, downstream execution, generic shell authority, self-authorization, or new authority was introduced.

Approval, Delegation, Validation, Envelope Gate, Envelope, and Execution remain distinct authority boundaries.

## Authorization consumption

- Live Governance Validation authorization: CONSUMED
- Live Envelope Gate creation authorization: CONSUMED
- Live Envelope creation validation authorization: CONSUMED
- Additional live mutation authorization: NONE

## Classification

`LIVE_ENVELOPE_CREATION_VALIDATED`

The Live Envelope Creation Validation boundary is CLOSED.

Any successor governance or execution effect remains separately bounded and requires its own authority.
DOC

printf '\n====================================================\n'
printf ' LIVE ENVELOPE CREATION VALIDATION — CLOSED\n'
printf '====================================================\n\n'

echo "EXACT_AUTHORIZED_DELEGATION=PASS"
echo "EXACT_PASSED_VALIDATION=PASS"
echo "EXACT_OPEN_GATE=PASS"
echo "EXACT_CREATED_ENVELOPE=PASS"
echo "AUTHORITATIVE_CAPABILITY_SEMANTICS=PASS"
echo "AUTHORITATIVE_OPERATIONAL_SEMANTICS=PASS"
echo "LIVE_VALIDATION_AUTHORIZATION=CONSUMED"
echo "LIVE_GATE_AUTHORIZATION=CONSUMED"
echo "LIVE_ENVELOPE_AUTHORIZATION=CONSUMED"
echo "ADDITIONAL_LIVE_MUTATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "LIVE_ENVELOPE_CREATION_VALIDATION=CLOSED"
echo "CLASSIFICATION=LIVE_ENVELOPE_CREATION_VALIDATED"

git diff --check -- docs/checkpoints/LIVE_ENVELOPE_CREATION_VALIDATION_CLOSURE.md
git add -- docs/checkpoints/LIVE_ENVELOPE_CREATION_VALIDATION_CLOSURE.md
git commit -m "Close live Envelope creation validation"
git push origin "$BRANCH"
