#!/usr/bin/env bash
set -euo pipefail

echo "==== Phase 423.2 Step 1 Candidate Surface Inspection ===="

echo
echo "==== Inspect likely governance decision path ===="
sed -n '1,260p' src/governance/governance_decision_pipeline.ts || true
echo
sed -n '1,260p' src/governance/governance_policy_router.ts || true
echo
sed -n '1,260p' src/governance/governance_policy_engine.ts || true
echo
sed -n '1,260p' src/governance/governance_enforcement_evaluator.ts || true

echo
echo "==== Inspect likely gate surfaces ===="
sed -n '1,260p' src/governance/cognition/governance_authorization_gate.ts || true
echo
sed -n '1,260p' src/governance/cognition/build_governance_authorization_gate.ts || true
echo
sed -n '1,260p' src/governance/cognition/governance_live_wiring_decision.ts || true
echo
sed -n '1,260p' src/governance/cognition/build_governance_live_wiring_decision.ts || true
echo
sed -n '1,260p' src/governance/cognition/governance_live_registry_wiring_readiness.ts || true
echo
sed -n '1,260p' src/governance/cognition/build_governance_live_registry_wiring_readiness.ts || true

echo
echo "==== Inspect likely external entry surfaces ===="
sed -n '1,260p' src/pages/api/command.ts || true
echo
sed -n '1,260p' src/pages/api/task.ts || true
echo
sed -n '1,260p' src/lib/dispatch.ts || true
echo
sed -n '1,260p' src/agents/cade/processor.ts || true

echo
echo "==== Inspect runtime-facing registry surface ===="
sed -n '1,260p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts || true
echo
sed -n '1,260p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement.ts || true
echo
sed -n '1,260p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_runtime_guard.ts || true
echo
sed -n '1,260p' src/cognition/transport/consumptionRegistry/dashboardConsumption.registry.runtime.ts || true

echo
echo "==== End candidate inspection ===="
