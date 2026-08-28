#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD_PREFIX="5db6b9545"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== CORRIDOR 6 ROUTE ADAPTER SHAPE INSPECTION ==="
echo "EXPECTED_HEAD_PREFIX=${EXPECTED_HEAD_PREFIX}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "ROUTE_ACTIVATION_ATTEMPTED=NO"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== GOVERNANCE EXECUTION ROUTE EXPORTS ==="
grep -nE '^export |function handleGovernanceExecutionRouteRequest|type GovernanceExecutionRouteDependencies|interface GovernanceExecutionRouteDependencies' \
  server/routes/governance-execution-route.ts || true

echo
echo "=== ROUTE HANDLER IMPLEMENTATION ==="
sed -n '130,260p' server/routes/governance-execution-route.ts

echo
echo "=== PRODUCTION COMPOSITION EXPORTS ==="
grep -nE '^export |function createProductionGovernanceExecutionRouter|type |interface ' \
  server/execution/production-governance-execution-composition.ts || true

echo
echo "=== PRODUCTION COMPOSITION IMPLEMENTATION ==="
sed -n '1,260p' server/execution/production-governance-execution-composition.ts

echo
echo "=== EXISTING EXPRESS ROUTE MOUNT PATTERNS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E 'app\.(use|get|post|put|patch|delete)\(|Router\(\)|express\.Router\(' \
  server routes | head -n 220 || true

echo
echo "=== CURRENT SERVER MOUNT BOUNDARY ==="
sed -n '1,150p' server/index.ts

echo
echo "INSPECTION_COMPLETE=YES"
echo "NEXT_DECISION=DEFINE_MINIMAL_EXPRESS_ADAPTER_FOR_EXISTING_REQUEST_HANDLER"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
