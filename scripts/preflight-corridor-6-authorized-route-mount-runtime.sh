#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="97136bf1642ebcebd4015ce49c1db091a0ad2968"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== CORRIDOR 6 AUTHORIZED ROUTE MOUNT RUNTIME PREFLIGHT ==="
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "USER_INTENT_AUTHORITY=PRESENT"
echo "AUTHORITY_SOURCE=EXPLICIT_USER_CHAT_AUTHORIZATION"
echo "AUTHORIZED_UNIT=DEDICATED_ROUTE_MOUNT_AND_PRODUCTION_REACHABILITY_PLUS_TARGETED_TESTS"

echo
echo "=== SERVER IMPORT CONTEXT ==="
grep -nE '^import |app\.use\(' server/index.ts | head -120

echo
echo "=== PRODUCTION COMPOSITION ==="
sed -n '1,220p' server/execution/production-governance-execution-composition.mjs

echo
echo "=== MJS COMPOSITION RUNTIME PREFLIGHT ==="
npx tsx scripts/preflight-corridor-6-mjs-composition.mjs

echo
echo "=== TS SERVER -> MJS COMPOSITION IMPORT PREFLIGHT ==="
if npx tsx --eval 'import("./server/execution/production-governance-execution-composition.mjs").then((m) => { if (typeof m.createProductionGovernanceExecutionRouter !== "function") process.exit(2); console.log("TS_SERVER_TO_MJS_COMPOSITION_IMPORT=PASS"); })'; then
  echo "ROUTE_MOUNT_RUNTIME_HYPOTHESIS=SUPPORTED"
else
  echo "ROUTE_MOUNT_RUNTIME_HYPOTHESIS=FAILED"
  echo "IMPLEMENTATION_CHANGE=NONE"
  exit 1
fi

echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_STEP=IMPLEMENT_BOUNDED_ROUTE_MOUNT_IF_PREFLIGHT_PASSES"
