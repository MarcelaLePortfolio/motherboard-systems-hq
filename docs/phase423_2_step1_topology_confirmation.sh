#!/usr/bin/env bash
set -euo pipefail

echo "==== Phase 423.2 Step 1 Topology Confirmation ===="

echo
echo "==== Re-inspect recorded execution entry surface ===="
sed -n '1,220p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts || true
echo
sed -n '1,220p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_readonly_view.ts || true
echo
sed -n '1,220p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_bundle.ts || true

echo
echo "==== Re-inspect recorded governance chain surfaces ===="
sed -n '1,220p' src/governance/cognition/build_governance_live_registry_wiring_readiness.ts || true
echo
sed -n '1,220p' src/governance/cognition/build_governance_live_wiring_decision.ts || true
echo
sed -n '1,220p' src/governance/cognition/build_governance_authorization_gate.ts || true

echo
echo "==== Re-inspect recorded approval surfaces ===="
sed -n '1,220p' src/governance/governance_policy_engine.ts || true
echo
sed -n '1,220p' src/governance/governance_enforcement_contract.ts || true
echo
sed -n '1,220p' src/governance/governance_enforcement_result.ts || true

echo
echo "==== Alternate invocation / bypass scan ===="
grep -RniE 'runConsumptionRegistryEnforcementEntrypoint|createConsumptionRegistryEnforcementReadonlyView|createConsumptionRegistryEnforcementBundle|buildGovernanceLiveRegistryWiringReadiness|buildGovernanceLiveWiringDecision|buildGovernanceAuthorizationGate|evaluateGovernancePolicy' src || true

echo
echo "==== Debug / test harness scan for entry handler ===="
grep -RniE 'runConsumptionRegistryEnforcementEntrypoint' src test . || true

echo
echo "==== End topology confirmation ===="
