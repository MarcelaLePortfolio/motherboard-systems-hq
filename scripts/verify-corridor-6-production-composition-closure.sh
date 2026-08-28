#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="223e1463cae23dec2972c258afc4ea3b5430fdb7"

echo "=== CORRIDOR 6 PRODUCTION COMPOSITION VERIFICATION ==="

test "$(git rev-parse HEAD)" = "${EXPECTED_HEAD}"

npx tsx --test server/execution/production-governance-execution-composition.test.mjs
npx tsx --test server/routes/governance-execution-route.test.ts
npx tsx --test server/execution/production-execution-entry-point.test.ts
npx tsc --noEmit

if grep -q 'production-governance-execution-composition' server/index.ts; then
  echo "ERROR=PRODUCTION_ROUTE_MOUNT_DETECTED"
  exit 1
fi

echo "PRODUCTION_EXECUTION_COMPOSITION_BINDING=VERIFIED"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=UNCHANGED"
echo "NEW_AUTHORITY_INTRODUCED=NO"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_BOUNDARY=DEDICATED_ROUTE_MOUNT_AND_PRODUCTION_REACHABILITY"
