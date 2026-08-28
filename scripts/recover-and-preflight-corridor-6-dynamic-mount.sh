#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="8fe6e395c9cde7abc7732c709e7d50573c1e089b"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== CORRIDOR 6 FAILED MOUNT HYPOTHESIS RECOVERY ==="
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "FAILED_HYPOTHESIS=STATIC_TS_SERVER_IMPORT_OF_MJS_PRODUCTION_COMPOSITION"
echo "FAILURE_CLASS=KNOWN_APPROVAL_GATE_JS_SPECIFIER_RESOLUTION"
echo "FAILED_ATTEMPT_COMMITTED=NO"
echo "FAILED_ATTEMPT_PUSHED=NO"

git restore -- server/index.ts
rm -f \
  server/execution/production-governance-execution-mount.test.mjs \
  scripts/implement-corridor-6-dedicated-route-mount.sh

if ! git diff --quiet -- server/index.ts; then
  echo "RECOVERY_FAILED=SERVER_INDEX_NOT_AT_STABLE_HEAD"
  exit 1
fi

echo "FAILED_IMPLEMENTATION_RECOVERY=PASS"

echo
echo "=== EXISTING ASYNC BOOTSTRAP BOUNDARY ==="
grep -nE 'async function bootstrap|await import|app\.listen' server/index.ts

echo
echo "=== DYNAMIC BOOTSTRAP IMPORT PREFLIGHT ==="
npx tsx --eval '
(async () => {
  const path = await import("path");
  const { pathToFileURL } = await import("url");

  const compositionUrl = pathToFileURL(
    path.resolve(
      process.cwd(),
      "server",
      "execution",
      "production-governance-execution-composition.mjs",
    ),
  ).href;

  const composition = await import(compositionUrl);

  if (
    typeof composition.createProductionGovernanceExecutionRouter !== "function"
  ) {
    throw new Error(
      "createProductionGovernanceExecutionRouter export unavailable",
    );
  }

  const router =
    composition.createProductionGovernanceExecutionRouter();

  if (typeof router !== "function") {
    throw new Error("Production governance execution router construction failed");
  }

  console.log("DYNAMIC_COMPOSITION_IMPORT=PASS");
  console.log("PRODUCTION_ROUTER_CONSTRUCTION=PASS");
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
'

echo
echo "=== BASELINE SERVER IMPORT ==="
npx tsx --eval '
import("./server/index.ts")
  .then(() => {
    console.log("BASELINE_SERVER_IMPORT=PASS");
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
'

echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "STATIC_IMPORT_HYPOTHESIS=RETIRED"
echo "DYNAMIC_BOOTSTRAP_MOUNT_HYPOTHESIS=SUPPORTED"
echo "NEXT_STEP=IMPLEMENT_DYNAMIC_BOOTSTRAP_ROUTE_MOUNT"
