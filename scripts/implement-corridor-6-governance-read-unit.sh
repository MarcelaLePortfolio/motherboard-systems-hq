#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="beadd88a6"
[[ "$(git rev-parse HEAD)" == "$EXPECTED_HEAD"* ]] || {
  echo "STOP=UNEXPECTED_HEAD"
  exit 1
}

node --import tsx --test db/governance-execution-read-repository.test.ts
npx tsc --noEmit

git diff --exit-code "$EXPECTED_HEAD" -- server/index.ts
git diff --exit-code "$EXPECTED_HEAD" -- server/routes
git diff --exit-code "$EXPECTED_HEAD" -- server/execution/production-execution-entry-point.ts

echo "GOVERNANCE_READ_UNIT_IMPLEMENTED=YES"
echo "TARGETED_TESTS_PASSED=YES"
echo "TYPESCRIPT_PASSED=YES"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "CORRIDOR_6_STATUS=GOVERNANCE_READ_UNIT_IMPLEMENTED_PENDING_VERIFICATION"
echo "PHASE_1_STATUS=ACTIVE"
git status --short
