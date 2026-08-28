#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="286f931d78c1735f9a7239e162a4916671824507"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

rm -f \
  server/execution/execution-approval-gate.ts \
  server/execution/production-governance-execution-composition.ts \
  server/execution/production-governance-execution-composition-ts.test.ts \
  scripts/implement-corridor-6-typescript-runtime-seam.sh

echo "FAILED_TYPESCRIPT_SEAM_ATTEMPT_RECOVERY=PASS"

echo
echo "=== GOVERNANCE ROUTE IMPORT GRAPH ==="
grep -nE '^import|from "' server/routes/governance-execution-route.ts || true

echo
echo "=== MJS DEPENDENCIES REACHED BY GOVERNANCE ROUTE ==="
grep -RIn '\.mjs"' \
  server/routes/governance-execution-route.ts \
  server/execution/compile-persisted-execution-approval.mjs \
  2>/dev/null || true

echo
echo "=== COMPILED ROUTE REFERENCES ==="
npm run build
grep -nE 'require\(|\.mjs' dist/server/routes/governance-execution-route.js || true

echo
echo "=== BASELINE PRODUCTION RUNTIME ==="
node dist/server/index.js > /tmp/corridor-6-route-dependency-recovery.log 2>&1 &
SERVER_PID=$!
sleep 3

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
  cat /tmp/corridor-6-route-dependency-recovery.log
  echo "BASELINE_PRODUCTION_RUNTIME=FAIL"
  exit 1
fi

kill "${SERVER_PID}" 2>/dev/null || true
wait "${SERVER_PID}" 2>/dev/null || true

echo "BASELINE_PRODUCTION_RUNTIME=PASS"
echo "FAILED_HYPOTHESIS=TYPESCRIPT_COMPOSITION_WITH_EXISTING_ROUTE_RUNTIME_GRAPH"
echo "OBSERVED_BLOCKER=COMPILED_GOVERNANCE_ROUTE_REQUIRES_NONEMITTED_COMPILE_PERSISTED_EXECUTION_APPROVAL_MJS"
echo "NEXT_BOUNDARY=CLASSIFY_FULL_DIST_RUNTIME_GRAPH_FOR_GOVERNANCE_EXECUTION_ROUTE"
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
echo "PRODUCTION_CHANGE=NONE"
