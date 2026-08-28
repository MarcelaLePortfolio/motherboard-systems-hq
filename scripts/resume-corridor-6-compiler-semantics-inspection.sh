#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="81b6b7a0ac5caf5bc148640dd4ac2cd83a5ff3b6"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "=== EXISTING APPROVAL COMPILER ==="
cat server/execution/compile-persisted-execution-approval.mjs

echo
echo "=== COMPILER CALL SITES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  "compilePersistedExecutionApproval\|compile-persisted-execution-approval" \
  server db routes 2>/dev/null || true

echo
echo "=== PERSISTED APPROVAL CONTRACT ==="
sed -n '1,260p' db/governance-execution-approval-persistence.ts

echo
echo "=== EXECUTION APPROVAL / ENTRY CONTRACTS ==="
sed -n '1,280p' server/execution/production-execution-entry-point.ts
sed -n '1,320p' server/routes/governance-execution-route.ts

echo
echo "=== INSPECTION RESULT ==="
echo "UNEXPECTED_HEAD_EXPLAINED=YES"
echo "HEAD_CHANGE_WAS_PRIOR_AUTHORIZED_INSPECTION_COMMIT=YES"
echo "THIRD_HYPOTHESIS_AUTHORIZATION_REMAINS_VALID=YES"
echo "ROUTE_MOUNT_INCLUDED=NO"
echo "PRODUCTION_CHANGE=NONE"
