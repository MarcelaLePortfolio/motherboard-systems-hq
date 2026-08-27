#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="9c21067e0"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — CONTEXT-DEPENDENT APPROVAL GATE RESOLUTION CLASSIFICATION ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "ROUTE_IMPLEMENTATION_PRESENT=NO"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo

TMP_ROOT=".tmp-corridor-6-resolution-classification"
rm -rf "$TMP_ROOT"
mkdir -p "$TMP_ROOT"
trap 'rm -rf "$TMP_ROOT"' EXIT

echo "=== VERIFIED CONTRADICTION ==="
echo "DYNAMIC_IMPORT_FROM_NODE_EVAL=PASS"
echo "EXISTING_MJS_SMOKE_IMPORT=PASS"
echo "STATIC_IMPORT_THROUGH_TS_ROUTE_TEST=FAIL_PREVIOUSLY_OBSERVED"
echo "MISSING_RUNTIME_TARGET=matilda-execution-switch-evaluator.js"
echo "CANONICAL_SOURCE_TARGET=matilda-execution-switch-evaluator.ts"
echo "TSC_OUTPUT_TARGET=matilda-execution-switch-evaluator.js"
echo

echo "=== CONTROL A — MJS STATIC IMPORTER ==="
cat > "$TMP_ROOT/import-approval-gate.mjs" <<'NODE'
import "../server/execution/execution-approval-gate.mjs";
console.log("CONTROL_A_MJS_STATIC_IMPORT=PASS");
NODE

set +e
node --import tsx "$TMP_ROOT/import-approval-gate.mjs"
CONTROL_A_RC=$?
set -e
echo "CONTROL_A_RC=$CONTROL_A_RC"
echo

echo "=== CONTROL B — TS STATIC IMPORTER ==="
cat > "$TMP_ROOT/import-approval-gate.ts" <<'NODE'
import "../server/execution/execution-approval-gate.mjs";
console.log("CONTROL_B_TS_STATIC_IMPORT=PASS");
NODE

set +e
node --import tsx "$TMP_ROOT/import-approval-gate.ts"
CONTROL_B_RC=$?
set -e
echo "CONTROL_B_RC=$CONTROL_B_RC"
echo

echo "=== CONTROL C — TS NODE TEST STATIC IMPORTER ==="
cat > "$TMP_ROOT/import-approval-gate.test.ts" <<'NODE'
import test from "node:test";
import "../server/execution/execution-approval-gate.mjs";

test("approval gate static import control", () => {
  console.log("CONTROL_C_TS_NODE_TEST_STATIC_IMPORT=PASS");
});
NODE

set +e
node --import tsx --test "$TMP_ROOT/import-approval-gate.test.ts"
CONTROL_C_RC=$?
set -e
echo "CONTROL_C_RC=$CONTROL_C_RC"
echo

echo "=== CONTROL D — DIRECT CANONICAL TS IMPORT ==="
cat > "$TMP_ROOT/import-evaluator.ts" <<'NODE'
import * as evaluator from "../server/execution/matilda-execution-switch-evaluator.ts";

console.log("CONTROL_D_DIRECT_TS_IMPORT=PASS");
console.log(
  "CONTROL_D_NAMED_EXPORT_TYPE=" +
    typeof evaluator.evaluateExecutionSwitch,
);
console.log(
  "CONTROL_D_DEFAULT_EXPORT_TYPE=" +
    typeof (evaluator as any).default,
);
NODE

set +e
node --import tsx "$TMP_ROOT/import-evaluator.ts"
CONTROL_D_RC=$?
set -e
echo "CONTROL_D_RC=$CONTROL_D_RC"
echo

echo "=== CONTROL E — SOURCE DIRECTORY STATIC IMPORTER ==="
cat > server/execution/.corridor-6-import-control.ts <<'NODE'
import "./execution-approval-gate.mjs";
console.log("CONTROL_E_SOURCE_DIR_TS_STATIC_IMPORT=PASS");
NODE

cleanup_source_probe() {
  rm -f server/execution/.corridor-6-import-control.ts
}
trap 'cleanup_source_probe; rm -rf "$TMP_ROOT"' EXIT

set +e
node --import tsx server/execution/.corridor-6-import-control.ts
CONTROL_E_RC=$?
set -e
cleanup_source_probe
echo "CONTROL_E_RC=$CONTROL_E_RC"
echo

echo "=== PACKAGE / MODULE MODE ==="
node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
console.log("PACKAGE_TYPE=" + String(pkg.type ?? "UNSET"));
console.log("PACKAGE_MAIN=" + String(pkg.main ?? "UNSET"));
NODE
echo

echo "=== APPROVAL GATE IMPORT EDGE ==="
grep -n \
  'matilda-execution-switch-evaluator' \
  server/execution/execution-approval-gate.mjs
echo

echo "=== EVALUATOR IMPORT EDGE ==="
grep -n \
  'matilda-execution-registry-loader' \
  server/execution/matilda-execution-switch-evaluator.ts
echo

echo "=== SOURCE / BUILD CONTRACT ==="
if [[ -f server/execution/matilda-execution-switch-evaluator.js ]]; then
  echo "SOURCE_JS_EVALUATOR_PRESENT=YES"
else
  echo "SOURCE_JS_EVALUATOR_PRESENT=NO"
fi

if [[ -f server/execution/matilda-execution-switch-evaluator.ts ]]; then
  echo "SOURCE_TS_EVALUATOR_PRESENT=YES"
else
  echo "SOURCE_TS_EVALUATOR_PRESENT=NO"
fi

rm -rf "$TMP_ROOT/build"
mkdir -p "$TMP_ROOT/build"

npx tsc \
  --outDir "$TMP_ROOT/build" \
  --rootDir . \
  --module NodeNext \
  --moduleResolution NodeNext \
  --target ES2021 \
  --esModuleInterop \
  --allowSyntheticDefaultImports \
  --skipLibCheck \
  --resolveJsonModule \
  --types node \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-registry-loader.ts

if [[ -f "$TMP_ROOT/build/server/execution/matilda-execution-switch-evaluator.js" ]]; then
  echo "BUILD_JS_EVALUATOR_PRESENT=YES"
else
  echo "BUILD_JS_EVALUATOR_PRESENT=NO"
fi

if [[ -f "$TMP_ROOT/build/server/execution/matilda-execution-registry-loader.js" ]]; then
  echo "BUILD_JS_REGISTRY_LOADER_PRESENT=YES"
else
  echo "BUILD_JS_REGISTRY_LOADER_PRESENT=NO"
fi
echo

echo "=== CLASSIFICATION ==="
echo "CONTROL_A_MJS_STATIC_IMPORT_RC=$CONTROL_A_RC"
echo "CONTROL_B_TS_STATIC_IMPORT_RC=$CONTROL_B_RC"
echo "CONTROL_C_TS_NODE_TEST_STATIC_IMPORT_RC=$CONTROL_C_RC"
echo "CONTROL_D_DIRECT_CANONICAL_TS_IMPORT_RC=$CONTROL_D_RC"
echo "CONTROL_E_SOURCE_DIR_TS_STATIC_IMPORT_RC=$CONTROL_E_RC"

if \
  [[ "$CONTROL_A_RC" -eq 0 ]] &&
  [[ "$CONTROL_B_RC" -ne 0 ]] &&
  [[ "$CONTROL_C_RC" -ne 0 ]]
then
  echo "RESOLUTION_CLASS=IMPORTER_CONTEXT_DEPENDENT_TSX_MJS_JS_SPECIFIER_RESOLUTION"
  echo "PREEXISTING_APPROVAL_GATE_CAPABILITY_BROKEN_UNIVERSALLY=NO"
  echo "ROUTE_TEST_CONTEXT_INCOMPATIBLE_WITH_CURRENT_APPROVAL_GATE_IMPORT_EDGE=YES"
  echo "MINIMUM_REPAIR_ESTABLISHED=NO"
  echo "REPAIR_OWNER_REQUIRES_FURTHER_BOUNDARY_DETERMINATION=YES"
elif \
  [[ "$CONTROL_A_RC" -eq 0 ]] &&
  [[ "$CONTROL_B_RC" -eq 0 ]] &&
  [[ "$CONTROL_C_RC" -eq 0 ]]
then
  echo "RESOLUTION_CLASS=MINIMAL_IMPORT_CONTROLS_ALL_PASS"
  echo "PREVIOUS_ROUTE_FAILURE_REQUIRES_ROUTE_SPECIFIC_IMPORT_GRAPH_INVESTIGATION=YES"
  echo "MINIMUM_REPAIR_ESTABLISHED=NO"
  echo "REPAIR_OWNER_REQUIRES_FURTHER_BOUNDARY_DETERMINATION=YES"
else
  echo "RESOLUTION_CLASS=MIXED_RUNTIME_BEHAVIOR_REQUIRES_FURTHER_CLASSIFICATION"
  echo "MINIMUM_REPAIR_ESTABLISHED=NO"
  echo "REPAIR_OWNER_REQUIRES_FURTHER_BOUNDARY_DETERMINATION=YES"
fi

echo
echo "=== AUTHORIZATION BOUNDARY ==="
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"
echo "RUNTIME_REPAIR_AUTHORIZED=NO"
echo "ROUTE_REIMPLEMENTATION_AUTHORIZED_FOR_THIS_STEP=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "GENERIC_CADE_CHANGE_AUTHORIZED=NO"
echo "GIT_EFFECT_CHANGE_AUTHORIZED=NO"
echo

echo "=== RESULT ==="
echo "APPROVAL_GATE_RUNTIME_CONTRADICTION_CLASSIFIED=YES"
echo "SPECULATIVE_FIX_APPLIED=NO"
echo "CORRIDOR_6_STATUS=ACTIVE_BLOCKED_ON_RUNTIME_BOUNDARY_CLASSIFICATION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=DETERMINE_EXACT_MINIMUM_OWNER_FROM_CONTROL_RESULTS_BEFORE_REQUESTING_ANY_NEW_IMPLEMENTATION_AUTHORIZATION"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
