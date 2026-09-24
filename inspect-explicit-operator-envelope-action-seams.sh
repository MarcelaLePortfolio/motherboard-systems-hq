#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="82b1f832d"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE ACTION — SEAM INSPECTION\n'
printf '====================================================\n\n'

printf '\n=== GOVERNANCE ENVELOPE ROUTE ===\n'
sed -n '1,260p' server/routes/governance-envelope-route.ts

printf '\n=== GOVERNANCE ENVELOPE ROUTE TEST ===\n'
sed -n '1,340p' server/routes/governance-envelope-route.test.ts

printf '\n=== CLIENT ENVELOPE / GATE API FILES ===\n'
find client/src/approvals -maxdepth 1 -type f | sort | grep -Ei 'envelope|gate|validation|approval'

printf '\n=== CLIENT GOVERNANCE ENVELOPE REFERENCES ===\n'
grep -RniE \
  'governance.*envelope|Envelope|envelopeGate|envelope_gate_id|validationResultId|postGovernanceEnvelopeGate' \
  client/src/approvals \
  | head -n 320 || true

printf '\n=== APPROVALS WORKSPACE RELEVANT WINDOWS ===\n'
grep -nE \
  'validationResultId|envelopeGateComplete|Envelope Gate|postGovernanceEnvelopeGate|crypto.randomUUID|Validate' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

printf '\n=== CURRENT GATE API ===\n'
sed -n '1,260p' client/src/approvals/governanceEnvelopeGateApi.ts

printf '\n=== CURRENT GATE API TEST ===\n'
if test -f client/src/approvals/governanceEnvelopeGateApi.test.ts; then
  sed -n '1,320p' client/src/approvals/governanceEnvelopeGateApi.test.ts
fi

printf '\n=== EXISTING ENVELOPE CLIENT API IF ANY ===\n'
for f in \
  client/src/approvals/governanceEnvelopeApi.ts \
  client/src/approvals/governanceEnvelopeApi.test.ts
do
  if test -f "$f"; then
    printf '\n--- %s ---\n' "$f"
    sed -n '1,320p' "$f"
  fi
done

printf '\n=== ROUTE REGISTRATION ===\n'
grep -RniE \
  'governance-envelope-route|/api/governance/envelope' \
  server \
  | head -n 160 || true

printf '\n=== DECISION RULES ===\n'
echo "EXPLICIT_OPERATOR_CLICK_REQUIRED=YES"
echo "EXACT_RETURNED_GATE_ID_MUST_BE_RETAINED=YES"
echo "NO_LATEST_GATE_LOOKUP=YES"
echo "NO_LATEST_VALIDATION_LOOKUP=YES"
echo "CALLER_REQUIRED_CAPABILITIES_MUST_NOT_BE_AUTHORITATIVE=YES"
echo "CALLER_OPERATIONAL_CORRIDOR_MUST_NOT_BE_AUTHORITATIVE=YES"
echo "SERVER_CONSUMER_OWNS_AUTHORITATIVE_SEMANTIC_RESOLUTION=YES"
echo "NO_AUTOMATIC_GATE_TO_ENVELOPE=YES"
echo "NO_LIFECYCLE_TRANSITION=YES"
echo "NO_EXECUTION_AUTHORITY=YES"
echo "NO_NEW_AUTHORITY=YES"

printf '\n=== FAILURE ACCOUNTING ===\n'
echo "IMPLEMENTATION_FAILED_ATTEMPTS=1"
echo "THIS_ACTION=INSPECTION_ONLY"
echo "THIS_ACTION_COUNTS_AS_IMPLEMENTATION_ATTEMPT=NO"

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=CLASSIFY_EXACT_CLIENT_AND_ROUTE_EDIT_TARGETS"
echo "IMPLEMENTATION_CHANGE=NONE"

printf '\nEXPLICIT_OPERATOR_ENVELOPE_ACTION_SEAM_INSPECTION=COMPLETE\n'
