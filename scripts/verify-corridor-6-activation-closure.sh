#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="e8b4aecb7b2df8a39c3178eea3633809c8291d39"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== CORRIDOR 6 ACTIVATION CLOSURE VERIFICATION ==="
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

npx tsx server/execution/production-governance-execution-composition.test.mjs
npx tsx server/execution/production-governance-execution-mount.test.mjs
npx tsx server/routes/governance-execution-route.test.ts
npx tsx server/execution/production-execution-entry-point.test.ts
npx tsx db/governance-execution-read-repository.test.ts
npx tsx db/governance-execution-approval-persistence.test.ts
npx tsx db/governance-execution-scope-persistence.test.ts
npx tsc --noEmit

npx tsx --eval '
import("./server/index.ts")
  .then(() => {
    console.log("PRODUCTION_SERVER_IMPORT=PASS");
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
'

grep -q 'production-governance-execution-composition.mjs' server/index.ts
test "$(grep -c 'app.use(createProductionGovernanceExecutionRouter());' server/index.ts)" -eq 1

echo "DEDICATED_ROUTE_MOUNTED=YES"
echo "PRODUCTION_REACHABILITY=YES"
echo "DURABLE_APPROVAL_REQUIRED=YES"
echo "DURABLE_EXECUTION_SCOPE_REQUIRED=YES"
echo "DURABLE_GOVERNANCE_CHAIN_REQUIRED=YES"
echo "CLIENT_AUTHORED_AUTHORITY_REJECTED=YES"
echo "COMMIT_AND_PUSH_AUTHORITY_SEPARATED=YES"
echo "PUSH_REQUIRES_CORRELATED_LOCAL_COMMIT_PROOF=YES"
echo "GENERIC_CADE_REACHABILITY_EXPANDED=NO"
echo "GENERIC_SHELL_OR_MUTATION_AUTHORITY_EXPANDED=NO"
echo "SCHEDULER_OR_AUTONOMY_EXPANDED=NO"
echo "NEW_AUTHORITY_INTRODUCED=NO"
echo "CORRIDOR_6_STATUS=CLOSED"
echo "PHASE_1_STATUS=CLOSED"
