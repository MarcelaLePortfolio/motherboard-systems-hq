#!/usr/bin/env bash
set -euo pipefail

echo "==== Phase 423.2 Step 1 Remaining Anchor Resolution ===="

echo
echo "==== Inspect activation candidate surfaces ===="
sed -n '1,260p' src/governance/cognition/build_governance_live_registry_wiring_readiness.ts || true
echo
sed -n '1,260p' src/governance/cognition/build_governance_live_wiring_decision.ts || true

echo
echo "==== Inspect approval candidate surfaces ===="
sed -n '1,260p' src/governance/governance_policy_engine.ts || true
echo
sed -n '1,260p' src/governance/governance_enforcement_contract.ts || true
echo
sed -n '1,260p' src/governance/governance_enforcement_result.ts || true

echo
echo "==== End remaining anchor resolution ===="
