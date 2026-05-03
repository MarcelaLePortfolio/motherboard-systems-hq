#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase425_step2_gateway_chokepoint_context_trace.txt"

{
echo "PHASE 425 — STEP 2"
echo "Governance Gateway Chokepoint Context Trace"
echo "-------------------------------------------"
echo

echo "buildGovernanceAuthorizationGate local context"
grep -R -n -C 4 "buildGovernanceAuthorizationGate" src || true
echo

echo "evaluateGovernancePolicy local context"
grep -R -n -C 4 "evaluateGovernancePolicy" src || true
echo

echo "governance decision builder local context"
grep -R -n -C 4 "buildGovernance.*Decision\|Governance.*Decision.*Builder" src || true
echo

echo "governance registry builder local context"
grep -R -n -C 4 "Governance.*Registry\|build.*Governance.*Registry" src || true
echo

echo "decision aggregation local context"
grep -R -n -C 3 -E "Decision|Authorization|Eligibility|Policy" src | grep -C 3 "Governance" || true
echo

echo "execution entrypoint proximity to governance gateway candidates"
grep -R -n -C 4 "runConsumptionRegistryEnforcementEntrypoint\|buildGovernanceAuthorizationGate\|evaluateGovernancePolicy" src || true
echo

} > "$OUTPUT"
