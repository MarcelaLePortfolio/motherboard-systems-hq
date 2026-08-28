#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="ce3a0bf0a3a60f3361b6575c88c9e7abe3113055"
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
echo "=== AUTHORIZED THIRD HYPOTHESIS ==="
echo "USER_INTENT_AUTHORITY=PRESENT"
echo "AUTHORIZED_UNIT=REACHABLE_NONEMITTED_RUNTIME_SEAM_CONVERSION_PLUS_TYPESCRIPT_PRODUCTION_COMPOSITION_AND_COMPILED_DIST_VERIFICATION"
echo "FIRST_REQUIRED_CONVERSION=COMPILE_PERSISTED_EXECUTION_APPROVAL"
echo "ROUTE_MOUNT_INCLUDED=NO"
echo "PRODUCTION_REACHABILITY_CHANGE_INCLUDED=NO"
echo "NEXT_ACTION=IMPLEMENT_ONLY_AFTER_EXACT_SEMANTIC_EQUIVALENCE_IS_ESTABLISHED"
echo "PRODUCTION_CHANGE=NONE"
