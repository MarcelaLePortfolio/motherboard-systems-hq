#!/usr/bin/env bash
set -euo pipefail

echo "=== ENTRYPOINT ==="
sed -n '1,200p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts

echo ""
echo "=== GOVERNANCE SNAPSHOT HELPER ==="
sed -n '1,220p' src/governance/cognition/get_governance_execution_eligibility_snapshot.ts

echo ""
echo "=== DOWNSTREAM EXECUTION INTERNALS CHECK ==="
git diff --name-only 1a98ec17..HEAD -- src/cognition/transport src/governance/cognition

echo ""
echo "=== RESULT SHAPE FIELDS CHECK ==="
grep -n "blockedByGovernance" src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts
grep -n "governanceReason" src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts

echo ""
echo "=== GOVERNANCE GATE IMPORT CHECK ==="
grep -n "getGovernanceExecutionEligibilitySnapshot" src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts

echo ""
echo "Phase 423.3 verification scan complete."
