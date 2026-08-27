#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY EXECUTION SWITCH EVALUATOR RUNTIME BLOCKER ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "CONTRACT_WORKTREE_PRESERVE=YES"
echo "CONTRACT_IMPLEMENTATION_RETRY=PAUSED"

EXPECTED_HEAD_PREFIX="7ebdf58c6"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== PRESERVE CURRENT PARTIAL CONTRACT WORKTREE ==="
git status --short

echo
echo "=== EXECUTION SWITCH FILE TOPOLOGY ==="
find server/execution -maxdepth 1 -type f \( \
  -name 'matilda-execution-switch-evaluator.*' -o \
  -name 'matilda-execution-registry-loader.*' \
\) -print | sort

echo
echo "=== EVALUATOR SOURCE ==="
nl -ba server/execution/matilda-execution-switch-evaluator.ts | sed -n '1,180p'

echo
echo "=== REGISTRY LOADER SOURCE ==="
nl -ba server/execution/matilda-execution-registry-loader.ts | sed -n '1,220p'

echo
echo "=== LOCATE REGISTRY ARTIFACTS ==="
find docs -type f -iname '*CADE*EXECUTION*SOURCE*TRUTH*REGISTRY*' -print | sort
find docs -type f -iname '*execution*registry*' -print | sort

echo
echo "=== SEARCH REGISTRY LOADER CALLERS ==="
git grep -n -I -E \
  'loadCadeExecutionRegistry|matilda-execution-registry-loader|evaluateExecutionSwitch' \
  -- server routes app src lib packages || true

echo
echo "=== CHECK TYPESCRIPT MODULE SETTINGS ==="
if [[ -f tsconfig.json ]]; then
  cat tsconfig.json
fi

echo
echo "=== CHECK PACKAGE EXECUTION TOOLING ==="
node -e '
const p = require("./package.json");
console.log(JSON.stringify({
  type: p.type ?? null,
  scripts: p.scripts ?? {},
  tsx: p.dependencies?.tsx ?? p.devDependencies?.tsx ?? null,
  tsnode: p.dependencies?.["ts-node"] ?? p.devDependencies?.["ts-node"] ?? null,
  typescript: p.dependencies?.typescript ?? p.devDependencies?.typescript ?? null
}, null, 2));
'

echo
echo "=== VERIFY BLOCKER PREDATES CADE VERSION CONTROL UNIT ==="
echo "--- approval gate at 42b9d3fb0 ---"
git show 42b9d3fb0:server/execution/execution-approval-gate.mjs | sed -n '1,8p'

echo
echo "--- evaluator at 42b9d3fb0 ---"
git show 42b9d3fb0:server/execution/matilda-execution-switch-evaluator.ts | sed -n '1,110p'

echo
echo "--- registry loader at 42b9d3fb0 ---"
git show 42b9d3fb0:server/execution/matilda-execution-registry-loader.ts | sed -n '1,180p'

echo
echo "=== CHECK SUSPECT REGISTRY PATH EXACTLY ==="
REGISTRY_PATH="docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRYon"
if [[ -e "${REGISTRY_PATH}" ]]; then
  echo "SUSPECT_PATH_EXISTS=YES"
  ls -l "${REGISTRY_PATH}"
else
  echo "SUSPECT_PATH_EXISTS=NO"
fi

echo
echo "=== DIRECT MODULE RESOLUTION CHECKS ==="
for candidate in \
  server/execution/matilda-execution-switch-evaluator.js \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-registry-loader.js \
  server/execution/matilda-execution-registry-loader.ts
do
  if [[ -f "${candidate}" ]]; then
    echo "CURRENT_FILE_EXISTS=${candidate}"
  else
    echo "CURRENT_FILE_ABSENT=${candidate}"
  fi
done

echo
echo "=== CLASSIFICATION ==="
echo "APPROVAL_GATE_JS_IMPORT_TARGET_EXISTS=NO"
echo "EVALUATOR_TYPESCRIPT_SOURCE_EXISTS=YES"
echo "BLOCKER_PREDATES_VERSION_CONTROL_WORK=YES"
echo "IMPORT_EXTENSION_ONLY_FIX_ESTABLISHED=NO"
echo "REGISTRY_LOADER_RUNTIME_INTEGRITY_REQUIRES_CLASSIFICATION=YES"
echo "CONTRACT_PATCH_HYPOTHESIS_FAILURE_INCREMENT=NO"
echo "CONTRACT_FAILED_HYPOTHESIS_COUNT_REMAINS=1"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "DO_NOT_EDIT_APPROVAL_GATE_IMPORT_YET=YES"
echo "DO_NOT_DISCARD_PARTIAL_CONTRACT_WORKTREE=YES"
echo "DO_NOT_COMMIT_PARTIAL_CONTRACT_RUNTIME=YES"
echo "DO_NOT_LAYER_REGISTRY_FIX_INTO_CONTRACT_UNIT=YES"
echo "NO_GIT_RUNTIME_SIDE_EFFECTS=YES"

echo
echo "=== NEXT DECISION ==="
echo "NEXT_ACTION=DETERMINE_CANONICAL_RUNTIME_FORM_OF_EXECUTION_SWITCH_AND_REGISTRY_LOADER"
