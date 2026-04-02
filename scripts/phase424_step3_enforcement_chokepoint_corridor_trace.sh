#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase424_step3_enforcement_chokepoint_corridor_trace.txt"

{
echo "PHASE 424 — STEP 3"
echo "Enforcement Chokepoint Corridor Proof"
echo "-------------------------------------"
echo

echo "execution entrypoint local context"
grep -R -n -C 3 "runConsumptionRegistryEnforcementEntrypoint" src || true
echo

echo "governance authorization local context"
grep -R -n -C 3 "buildGovernanceAuthorizationGate" src || true
echo

echo "governance evaluation local context"
grep -R -n -C 3 "evaluateGovernancePolicy" src || true
echo

echo "operator approval local context"
grep -R -n -C 3 -i "operator.*approval\|approval.*operator" src || true
echo

echo "invariant local context"
grep -R -n -C 2 -i "invariant" src || true
echo

echo "candidate chokepoint files"
grep -R -n -E "runConsumptionRegistryEnforcementEntrypoint|buildGovernanceAuthorizationGate|evaluateGovernancePolicy|operator.*approval|approval.*operator|invariant" src || true
echo

echo "candidate builder and decision seams"
grep -R -n -E "build.*Gate|build.*Decision|create.*Gate|create.*Decision|evaluate.*Policy|authorization.*gate|eligibility.*gate" src || true
echo

} > "$OUTPUT"
