#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DETERMINE CANONICAL EXECUTION SWITCH RUNTIME FORM ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "CONTRACT_WORKTREE_PRESERVE=YES"
echo "CONTRACT_IMPLEMENTATION_RETRY=PAUSED"

EXPECTED_HEAD_PREFIX="8aa954bae"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== PRESERVE PARTIAL CONTRACT WORK ==="
git status --short

echo
echo "=== BUILD / START CONTRACT ==="
node - <<'NODE'
const p = require("./package.json");
console.log(JSON.stringify({
  build: p.scripts?.build ?? null,
  start: p.scripts?.start ?? null,
  dev: p.scripts?.dev ?? null,
  check: p.scripts?.check ?? null,
  type: p.type ?? null
}, null, 2));
NODE

echo
echo "=== TSC MODULE CONTRACT ==="
node - <<'NODE'
const ts = require("./tsconfig.json");
console.log(JSON.stringify({
  module: ts.compilerOptions?.module,
  moduleResolution: ts.compilerOptions?.moduleResolution,
  outDir: ts.compilerOptions?.outDir,
  include: ts.include
}, null, 2));
NODE

echo
echo "=== CHECK EXISTING COMPILED EXECUTION ARTIFACTS ==="
for f in \
  dist/server/execution/execution-approval-gate.mjs \
  dist/server/execution/execution-approval-gate.js \
  dist/server/execution/matilda-execution-switch-evaluator.js \
  dist/server/execution/matilda-execution-registry-loader.js
do
  if [[ -f "$f" ]]; then
    echo "EXISTS=$f"
    nl -ba "$f" | sed -n '1,140p'
  else
    echo "ABSENT=$f"
  fi
done

echo
echo "=== VERIFY TYPESCRIPT COMPILE WITHOUT WRITING BUILD OUTPUT ==="
npx tsc --noEmit

echo
echo "=== TYPESCRIPT RESOLUTION TRACE FOR SWITCH / LOADER ==="
npx tsc --noEmit --traceResolution 2>&1 \
  | grep -E \
      'execution-approval-gate|matilda-execution-switch-evaluator|matilda-execution-registry-loader' \
  | sed -n '1,260p' || true

echo
echo "=== CHECK TSX SOURCE-RUNTIME RESOLUTION WITHOUT MUTATION ==="
npx tsx -e '
import { evaluateExecutionSwitch } from "./server/execution/matilda-execution-switch-evaluator.ts";
console.log("TSX_EVALUATOR_IMPORT=PASS");
console.log(typeof evaluateExecutionSwitch);
' || echo "TSX_EVALUATOR_IMPORT=FAIL"

echo
echo "=== CHECK REGISTRY ARTIFACT CONTENT / SHAPE ==="
for f in \
  docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json \
  docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.md
do
  echo
  echo "--- $f ---"
  if [[ -f "$f" ]]; then
    sed -n '1,220p' "$f"
  else
    echo "ABSENT"
  fi
done

echo
echo "=== REGISTRY LOADER PATH HISTORY ==="
git log --all --follow --date=iso \
  --format='%h %ad %s' \
  -- server/execution/matilda-execution-registry-loader.ts \
  | sed -n '1,80p'

echo
echo "=== SEARCH HISTORICAL REGISTRY PATH SPELLINGS ==="
git log -S'CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRYon' \
  --all --oneline -- \
  server/execution/matilda-execution-registry-loader.ts || true

git log -S'CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json' \
  --all --oneline -- \
  server/execution/matilda-execution-registry-loader.ts || true

echo
echo "=== RELATED REGISTRY VALIDATION SURFACES ==="
for f in \
  server/execution/matilda-execution-registry-validate.ts \
  server/execution/matilda-execution-transition-table.ts
do
  if [[ -f "$f" ]]; then
    echo
    echo "--- $f ---"
    nl -ba "$f" | sed -n '1,240p'
  fi
done

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=IS_JS_SPECIFIER_CANONICAL_FOR_COMPILED_NODENEXT_RUNTIME"
echo "QUESTION_2=DOES_TYPESCRIPT_RESOLVE_EXTENSIONLESS_TS_INTERNAL_IMPORTS_SUCCESSFULLY"
echo "QUESTION_3=DOES_TSX_PROVIDE_A_VALID_SOURCE_LEVEL_TEST_SURFACE"
echo "QUESTION_4=IS_REGISTRYon_A_CONFIRMED_PRE_EXISTING_PATH_DEFECT"
echo "QUESTION_5=IS_THE_JSON_REGISTRY_THE_CANONICAL_LOADER_TARGET"
echo "QUESTION_6=CAN_CONTRACT_TESTING_CONTINUE_WITHOUT_FIXING_EXECUTION_SWITCH_RUNTIME"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "PARTIAL_CONTRACT_FILES_MUST_REMAIN_UNCOMMITTED=YES"
echo "NO_APPROVAL_GATE_IMPORT_EDIT=YES"
echo "NO_REGISTRY_LOADER_EDIT=YES"
echo "NO_GIT_RUNTIME_SIDE_EFFECTS=YES"
echo "CONTRACT_FAILED_HYPOTHESIS_COUNT_REMAINS=1"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_CANONICAL_RUNTIME_AND_ISOLATE_PRE_EXISTING_DEFECT_FROM_CONTRACT_TEST_METHOD"
