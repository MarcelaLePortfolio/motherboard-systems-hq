#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="95f6542d657705f8e14bfed97e75dd77c804f94c"

echo "=== CORRIDOR 6 ROUTE MOUNT BOUNDARY CLASSIFICATION ==="

test "$(git rev-parse HEAD)" = "${EXPECTED_HEAD}"

if grep -q 'production-governance-execution-composition' server/index.ts; then
  echo "ERROR=PRODUCTION_ROUTE_ALREADY_MOUNTED"
  exit 1
fi

grep -n 'app\.use' server/index.ts || true
grep -n 'createProductionGovernanceExecutionRouter' \
  server/execution/production-governance-execution-composition.mjs

echo "PRODUCTION_EXECUTION_COMPOSITION_BINDING=VERIFIED"
echo "DEDICATED_ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "NEXT_IMPLEMENTATION_UNIT=DEDICATED_ROUTE_MOUNT_AND_PRODUCTION_REACHABILITY"
echo "NEXT_UNIT_AUTHORIZED=NO"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
