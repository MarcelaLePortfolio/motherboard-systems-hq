#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="6a77dc8f474f7dc4b40b122f932a74e1fc5e534d"
CURRENT_HEAD="$(git rev-parse HEAD)"
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "=== CURRENT UNCOMMITTED THIRD-HYPOTHESIS FILES ==="
git status --short \
  server/execution/compile-persisted-execution-approval.ts \
  server/execution/execution-approval-gate.ts \
  server/execution/production-governance-execution-composition.ts \
  server/routes/governance-execution-route.ts

echo
echo "=== TYPESCRIPT COMPILER SOURCE ==="
sed -n '1,220p' server/execution/compile-persisted-execution-approval.ts

echo
echo "=== PACKAGE MODULE CONTRACT ==="
cat package.json

echo
echo "=== TSC CONFIG ==="
cat tsconfig.json

echo
echo "=== DIRECT TSX MODULE SHAPE ==="
npx tsx -e '
const mod = require("./server/execution/compile-persisted-execution-approval.ts");
console.log("EXPORT_KEYS=" + Object.keys(mod).sort().join(","));
console.log("COMPILER_EXPORT_TYPE=" + typeof mod.compilePersistedExecutionApproval);
if (typeof mod.compilePersistedExecutionApproval !== "function") {
  process.exit(1);
}
'

echo
echo "TS_MODULE_EXPORT=PASS"
echo "IMPLEMENTATION_COMMIT_CREATED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=USE_REPOSITORY_NATIVE_MODULE_LOADING_FOR_EQUIVALENCE_CHECK"
