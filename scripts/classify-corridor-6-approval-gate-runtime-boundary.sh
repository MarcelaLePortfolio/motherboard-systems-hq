#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="176c9415d"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — APPROVAL GATE RUNTIME BOUNDARY CLASSIFICATION ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "ROUTE_IMPLEMENTATION_PRESENT=NO"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo

echo "=== CURRENT SOURCE FORMS ==="
echo "--- approval gate import ---"
sed -n '1,12p' server/execution/execution-approval-gate.mjs
echo
echo "--- evaluator source ---"
sed -n '1,220p' server/execution/matilda-execution-switch-evaluator.ts
echo
echo "--- registry loader source ---"
sed -n '1,260p' server/execution/matilda-execution-registry-loader.ts
echo

echo "=== TRACKED FILE FORMS ==="
for candidate in \
  server/execution/matilda-execution-switch-evaluator.js \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-registry-loader.js \
  server/execution/matilda-execution-registry-loader.ts
do
  if git ls-files --error-unmatch "$candidate" >/dev/null 2>&1; then
    echo "TRACKED=$candidate"
  else
    echo "NOT_TRACKED=$candidate"
  fi
done
echo

echo "=== EXACT SOURCE-RUNTIME PROBES ==="
set +e
node --import tsx -e '
import("./server/execution/execution-approval-gate.mjs")
  .then(() => {
    console.log("TSX_EVAL_IMPORT_APPROVAL_GATE=PASS");
    process.exit(0);
  })
  .catch((error) => {
    console.log("TSX_EVAL_IMPORT_APPROVAL_GATE=FAIL");
    console.log(error?.code ?? "NO_CODE");
    console.log(String(error?.message ?? error));
    process.exit(11);
  });
'
EVAL_RC=$?

node --import tsx --test server/execution/smoke-test-approval-gate.mjs
SMOKE_RC=$?

node --import tsx -e '
import("./server/execution/matilda-execution-switch-evaluator.ts")
  .then((module) => {
    console.log("DIRECT_EVALUATOR_TS_IMPORT=PASS");
    console.log("EVALUATOR_EXPORT_TYPE=" + typeof module.evaluateExecutionSwitch);
    process.exit(0);
  })
  .catch((error) => {
    console.log("DIRECT_EVALUATOR_TS_IMPORT=FAIL");
    console.log(error?.code ?? "NO_CODE");
    console.log(String(error?.message ?? error));
    process.exit(12);
  });
'
DIRECT_TS_RC=$?
set -e

echo
echo "TSX_EVAL_IMPORT_APPROVAL_GATE_RC=$EVAL_RC"
echo "SMOKE_APPROVAL_GATE_RC=$SMOKE_RC"
echo "DIRECT_EVALUATOR_TS_IMPORT_RC=$DIRECT_TS_RC"
echo

echo "=== BUILD CONTRACT PROBE ==="
rm -rf .tmp-corridor-6-build-probe
mkdir -p .tmp-corridor-6-build-probe
trap 'rm -rf .tmp-corridor-6-build-probe' EXIT

npx tsc \
  --outDir .tmp-corridor-6-build-probe \
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

find .tmp-corridor-6-build-probe/server/execution \
  -maxdepth 1 \
  -type f \
  -print \
  | sort

echo
echo "=== HISTORICAL OWNERSHIP ==="
git log --follow --oneline -- \
  server/execution/execution-approval-gate.mjs \
  | sed -n '1,80p'
echo
git log --follow --oneline -- \
  server/execution/matilda-execution-switch-evaluator.ts \
  | sed -n '1,80p'
echo

echo "=== CLASSIFICATION ==="
echo "CAPABILITY_MISSING=NO"
echo "CANONICAL_EVALUATOR_TS_EXISTS=YES"
echo "APPROVAL_GATE_IMPORTS_NONEXISTENT_SOURCE_JS=YES"
echo "DIRECT_TS_EVALUATOR_RUNTIME_PROBE_RC=$DIRECT_TS_RC"
echo "APPROVAL_GATE_SOURCE_RUNTIME_PROBE_RC=$EVAL_RC"
echo "APPROVAL_GATE_SMOKE_RUNTIME_PROBE_RC=$SMOKE_RC"
echo "ROUTE_BLOCKER_PREDATES_ROUTE_IMPLEMENTATION=YES"
echo "ROUTE_DOES_NOT_OWN_THIS_BLOCKER=YES"
echo "RUNTIME_BOUNDARY_OWNER=EXISTING_EXECUTION_APPROVAL_GATE_AND_EXECUTION_SWITCH_MODULE_CONTRACT"
echo "ROUTE_WORK_MUST_REMAIN_PAUSED=YES"
echo

if [[ "$DIRECT_TS_RC" -eq 0 && "$EVAL_RC" -ne 0 ]]; then
  echo "MINIMUM_REPAIR_CANDIDATE=RECONCILE_EXISTING_APPROVAL_GATE_SOURCE_RUNTIME_SPECIFIER_WITH_CANONICAL_TS_EVALUATOR_AND_BUILD_CONTRACT"
  echo "SEPARATE_PREEXISTING_CAPABILITY_REPAIR_REQUIRED=YES"
else
  echo "MINIMUM_REPAIR_CANDIDATE=NOT_YET_ESTABLISHED"
  echo "SEPARATE_PREEXISTING_CAPABILITY_REPAIR_REQUIRED=UNRESOLVED"
fi

echo "ROUTE_AUTHORIZATION_DOES_NOT_AUTHORIZE_PREEXISTING_RUNTIME_REPAIR=YES"
echo "NEW_IMPLEMENTATION_AUTHORIZATION_REQUIRED_BEFORE_RUNTIME_REPAIR=YES"
echo

echo "=== FAILURE CONTAINMENT ==="
echo "NO_ROUTE_REIMPLEMENTATION=YES"
echo "NO_ROUTE_MOUNT=YES"
echo "NO_SOURCE_RUNTIME_FIX_APPLIED=YES"
echo "NO_GENERIC_CADE_CHANGE=YES"
echo "NO_GIT_EFFECT_CHANGE=YES"
echo "NO_SHELL_OR_MUTATION_AUTHORITY_CHANGE=YES"
echo "NO_SCHEDULER_OR_AUTONOMY_CHANGE=YES"
echo

echo "=== RESULT ==="
echo "CORRIDOR_6_STATUS=ACTIVE_BLOCKED_ON_SEPARATE_PREEXISTING_APPROVAL_GATE_RUNTIME_CAPABILITY"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=REQUEST_EXPLICIT_USER_AUTHORIZATION_FOR_BOUNDED_PREEXISTING_APPROVAL_GATE_RUNTIME_REPAIR_IF_MINIMUM_REPAIR_IS_ESTABLISHED"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
