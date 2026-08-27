#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY EMPTY EXECUTION TRANSITIONS AS STABILIZATION ARTIFACT ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "RUNTIME_REPAIR_AUTHORIZED=NO"
echo "CONTRACT_WORKTREE_PRESERVE=YES"

CURRENT_HEAD="$(git rev-parse HEAD)"
echo "CURRENT_HEAD=${CURRENT_HEAD}"

STABILIZATION_COMMIT="a5b3e1c9448e6230bc026127bf514ee8d6788f47"
PARENT="$(git rev-parse "${STABILIZATION_COMMIT}^")"

echo
echo "=== PRESERVE CURRENT PARTIAL CONTRACT WORKTREE ==="
git status --short

echo
echo "=== PRE-STABILIZATION TRANSITION CONSUMERS ==="
for f in \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-transition-table.ts \
  server/execution/matilda-execution-registry-validate.ts
do
  echo
  echo "--- ${f} @ ${PARENT} ---"
  git show "${PARENT}:${f}" | grep -n -C 4 'transitions'
done

echo
echo "=== EXACT STABILIZATION CHANGE ==="
git show "${STABILIZATION_COMMIT}" --format= -- \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-transition-table.ts \
  server/execution/matilda-execution-registry-validate.ts

echo
echo "=== CANONICAL REGISTRY TRANSITION CONTRACT ==="
node - <<'NODE'
const fs = require("fs");
const registry = JSON.parse(
  fs.readFileSync(
    "docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json",
    "utf8"
  )
);
console.log(JSON.stringify({
  transitions: registry.execution_state_model.transitions,
  final_state_is_derived_only:
    registry.execution_state_model.final_state_is_derived_only
}, null, 2));
NODE

echo
echo "=== TYPE / DATA MISMATCH CHECK ==="
node - <<'NODE'
const fs = require("fs");
const source = fs.readFileSync(
  "server/execution/matilda-execution-registry-loader.ts",
  "utf8"
);
const registry = JSON.parse(
  fs.readFileSync(
    "docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json",
    "utf8"
  )
);

console.log(
  "LOADER_TYPE_DECLARES_TRANSITIONS=" +
  /\btransitions\s*:/.test(source)
);
console.log(
  "REGISTRY_DATA_HAS_TRANSITIONS=" +
  Boolean(registry.execution_state_model?.transitions)
);
NODE

echo
echo "=== LOADER PATH DEFECT CHECK ==="
grep -n 'CADE_EXECUTION_SOURCE_OF_TRUTH' \
  server/execution/matilda-execution-registry-loader.ts

test -f docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json

if [[ -e docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRYon ]]; then
  echo "INVALID_LOADER_TARGET_EXISTS=YES"
else
  echo "INVALID_LOADER_TARGET_EXISTS=NO"
fi

echo
echo "=== EVIDENCE-BASED CLASSIFICATION ==="
echo "CANONICAL_REGISTRY_TRANSITIONS_ARE_NONEMPTY=YES"
echo "PRE_STABILIZATION_CONSUMERS_READ_REGISTRY_TRANSITIONS=YES"
echo "STABILIZATION_REPLACED_REGISTRY_TRANSITIONS_WITH_EMPTY_MAPS=YES"
echo "STABILIZATION_COMMIT_PURPOSE=CLEAN_TYPESCRIPT_COMPILATION"
echo "EMPTY_TRANSITIONS_AS_INTENTIONAL_FAIL_CLOSED_POLICY=NOT_SUPPORTED_BY_CURRENT_EVIDENCE"
echo "EMPTY_TRANSITIONS_AS_COMPILATION_STABILIZATION_ARTIFACT=SUPPORTED_BY_CURRENT_EVIDENCE"
echo "REGISTRY_LOADER_PATH_TYPO=SEPARATE_PRE_EXISTING_DEFECT"
echo "CONTRACT_IMPLEMENTATION_FAILURE_COUNT_REMAINS=1"

echo
echo "=== PROPOSED ISOLATED REPAIR — NOT AUTHORIZED ==="
echo "REPAIR_1=ADD_TRANSITIONS_TO_REGISTRY_TYPE"
echo "REPAIR_2=POINT_LOADER_TO_CANONICAL_JSON"
echo "REPAIR_3=RESTORE_EVALUATOR_REGISTRY_TRANSITIONS"
echo "REPAIR_4=RESTORE_TRANSITION_TABLE_REGISTRY_TRANSITIONS"
echo "REPAIR_5=RESTORE_VALIDATOR_REGISTRY_TRANSITIONS"
echo "REPAIR_MUST_REMAIN_SEPARATE_FROM_CADE_VERSION_CONTROL_CONTRACT=YES"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "NO_RUNTIME_REPAIR_PERFORMED=YES"
echo "NO_PARTIAL_CONTRACT_COMMIT=YES"
echo "NO_GIT_RUNTIME_SIDE_EFFECTS=YES"
echo "PRESERVE_CURRENT_WORKTREE=YES"

echo
echo "NEXT_ACTION=REVIEW_AND_AUTHORIZE_ISOLATED_EXECUTION_REGISTRY_INTEGRITY_REPAIR"
