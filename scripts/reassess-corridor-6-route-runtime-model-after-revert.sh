#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="113a36f39"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — POST-REVERT ROUTE / RUNTIME MODEL REASSESSMENT ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "THREE_FAILED_HYPOTHESIS_SEQUENCE=CLOSED"
echo

echo "=== STABLE BASE ==="
echo "REVERT_COMMIT=113a36f39"
echo "STABLE_PRE_ROUTE_CHECKPOINT=2bb9be31d"
echo "ROUTE_IMPLEMENTATION_PRESENT=NO"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo

echo "=== VERIFIED CURRENT CAPABILITIES ==="
for file in \
  db/governance-execution-approval-persistence.ts \
  db/governance-execution-scope-persistence.ts \
  db/governance-execution-read-repository.ts \
  server/execution/compile-persisted-execution-approval.mjs \
  server/execution/execution-approval-gate.mjs \
  server/execution/production-execution-entry-point.ts
do
  echo "--- $file ---"
  sed -n '1,360p' "$file"
  echo
done

echo "=== RUNTIME / TEST SURFACE TOPOLOGY ==="
find server/execution server/routes db \
  -maxdepth 2 \
  -type f \
  \( -name '*.ts' -o -name '*.mjs' -o -name '*.js' \) \
  | sort \
  | grep -E \
    'execution|governance|approval|envelope|delegation|validation' \
  | sed -n '1,420p'
echo

echo "=== EXISTING PRODUCTION BUILD CONTRACT ==="
cat package.json
echo
cat tsconfig.json
echo

echo "=== DIRECT APPROVAL GATE RUNTIME CHECKS ==="
echo "--- source runtime ---"
node --import tsx -e '
import("./server/execution/execution-approval-gate.mjs")
  .then(() => console.log("SOURCE_APPROVAL_GATE_IMPORT=PASS"))
  .catch((error) => {
    console.log("SOURCE_APPROVAL_GATE_IMPORT=FAIL");
    console.log(String(error?.message ?? error));
  });
'
echo

echo "--- compiled runtime candidates ---"
for candidate in \
  dist/server/execution/execution-approval-gate.js \
  dist/server/execution/execution-approval-gate.mjs
do
  if [[ -f "$candidate" ]]; then
    echo "EXISTS=$candidate"
    node -e "
      import('./$candidate')
        .then(() => console.log('COMPILED_APPROVAL_GATE_IMPORT=PASS'))
        .catch((error) => {
          console.log('COMPILED_APPROVAL_GATE_IMPORT=FAIL');
          console.log(String(error?.message ?? error));
        });
    "
  else
    echo "ABSENT=$candidate"
  fi
done
echo

echo "=== HISTORICAL PREEXISTING BLOCKER EVIDENCE ==="
git log --all --oneline -- \
  server/execution/execution-approval-gate.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-registry-loader.ts \
  | sed -n '1,120p'
echo

echo "=== REASSESSMENT QUESTIONS ==="
echo "Q1=IS_UNMOUNTED_ROUTE_STILL_THE_MINIMUM_SAFE_REACHABILITY_OWNER"
echo "Q2=CAN_ROUTE_BE_TESTED_WITHOUT_IMPORTING_PREEXISTING_BROKEN_SOURCE_APPROVAL_GATE"
echo "Q3=SHOULD_APPROVAL_GATE_BE_INJECTED_AS_A_ROUTE_DEPENDENCY_RATHER_THAN_IMPORTED_DIRECTLY"
echo "Q4=WOULD_DEPENDENCY_INJECTION_PRESERVE_PRODUCTION_APPROVAL_SEMANTICS_AND_REMOVE_TEST_RUNTIME_COUPLING"
echo "Q5=DOES_DEFAULT_PRODUCTION_BINDING_REQUIRE_A_SEPARATE_RUNTIME_REPAIR_BEFORE_ROUTE_MOUNTING"
echo "Q6=CAN_UNMOUNTED_ROUTE_IMPLEMENTATION_AND_PRODUCTION_BINDING_REMAIN_SEPARATE_UNITS"
echo

echo "=== GOVERNANCE BOUNDARY ==="
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"
echo "PREVIOUS_FAILED_HYPOTHESIS_REUSE=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "GENERIC_CADE_CHANGE_AUTHORIZED=NO"
echo "GENERIC_SHELL_OR_MUTATION_CHANGE_AUTHORIZED=NO"
echo "SCHEDULER_OR_AUTONOMY_CHANGE_AUTHORIZED=NO"
echo

echo "=== RESULT ==="
echo "CORRIDOR_6_STATUS=ACTIVE_REASSESSMENT"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=CLASSIFY_NEW_ROUTE_RUNTIME_BOUNDARY_FROM_STABLE_BASE"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
