#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e63044f8b"
DB="db/main.db"

ENVELOPE_ID="envelope-live-validation-20260924T060723Z"
ENVELOPE_GATE_ID="gate-live-envelope-validation-20260924T060547Z"
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
printf ' POST-ENVELOPE SUCCESSOR BOUNDARY — READ-ONLY CLASSIFICATION\n'
printf '====================================================\n\n'

printf '\n=== EXACT ENVELOPE ===\n'
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
WHERE envelope_id='$ENVELOPE_ID'
  AND envelope_gate_id='$ENVELOPE_GATE_ID'
  AND validation_result_id='$VALIDATION_RESULT_ID'
  AND delegation_id='$DELEGATION_ID'
  AND package_id='$PACKAGE_ID'
  AND package_version=$PACKAGE_VERSION;
"

printf '\n=== LIFECYCLE / ROUTING / ASSIGNMENT / EXECUTION CONTRACT REFERENCES ===\n'
grep -RniE \
  'ENVELOPE_CREATED|lifecycle.*transition|routing_authorized|assignment_authorized|scheduler_authorized|worker_claim_authorized|orchestration_authorized|execution_authorized|operational_corridor|required_capabilities' \
  server db docs/governance docs/checkpoints \
  | head -n 420 || true

printf '\n=== EXACT DOWNSTREAM READ REFERENCES ===\n'
grep -RniE \
  'governance_envelopes|envelope_id|envelope_gate_id|load.*envelope|read.*envelope|execution.*envelope|assignment.*envelope|routing.*envelope' \
  server db \
  | head -n 420 || true

printf '\n=== CURRENT AUTHORITY STATE ===\n'
echo "LIVE_VALIDATION_AUTHORIZATION=CONSUMED"
echo "LIVE_GATE_AUTHORIZATION=CONSUMED"
echo "LIVE_ENVELOPE_AUTHORIZATION=CONSUMED"
echo "ADDITIONAL_LIVE_MUTATION_AUTHORITY=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== CLASSIFICATION RULE ===\n'
echo "MODE=READ_ONLY"
echo "DO_NOT_MUTATE_LIFECYCLE=YES"
echo "DO_NOT_ROUTE=YES"
echo "DO_NOT_ASSIGN=YES"
echo "DO_NOT_SCHEDULE=YES"
echo "DO_NOT_CLAIM_WORKER=YES"
echo "DO_NOT_ORCHESTRATE=YES"
echo "DO_NOT_EXECUTE=YES"
echo "DO_NOT_INFER_SUCCESSOR_AUTHORITY=YES"
echo "NEXT_ACTION=CLASSIFY_SMALLEST_SEPARATELY_GOVERNED_SUCCESSOR_BOUNDARY"

printf '\nPOST_ENVELOPE_SUCCESSOR_BOUNDARY_INSPECTION=COMPLETE\n'
