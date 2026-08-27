#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE AND COMMIT EXECUTION REGISTRY INTEGRITY REPAIR ==="
echo "MODE=EXECUTION"
echo "SCOPE=FOUR_AUTHORIZED_REGISTRY_FILES_ONLY"
echo "CADE_VERSION_CONTROL_CONTRACT_WORK=UNCHANGED_AND_UNSTAGED"

EXPECTED_HEAD_PREFIX="44e6b6cb0"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

AUTHORIZED_FILES=(
  server/execution/matilda-execution-registry-loader.ts
  server/execution/matilda-execution-registry-validate.ts
  server/execution/matilda-execution-switch-evaluator.ts
  server/execution/matilda-execution-transition-table.ts
)

echo
echo "=== VERIFY AUTHORIZED FILES ARE MODIFIED ==="
for f in "${AUTHORIZED_FILES[@]}"; do
  if git diff --quiet -- "$f"; then
    echo "STOP: expected authorized repair change missing: $f"
    exit 1
  fi
  echo "MODIFIED=$f"
done

echo
echo "=== TYPESCRIPT VALIDATION ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== REGISTRY LOADER VALIDATION ==="
npx tsx -e '
import { loadCadeExecutionRegistry } from "./server/execution/matilda-execution-registry-loader.ts";
const r = loadCadeExecutionRegistry();
if (!r.execution_state_model.transitions) throw new Error("transitions missing");
if (r.execution_state_model.transitions.DISABLED?.[0] !== "ARMED") {
  throw new Error("canonical DISABLED -> ARMED transition missing");
}
console.log("REGISTRY_LOADER=PASS");
'

echo
echo "=== REGISTRY VALIDATOR ==="
npx tsx -e '
import { validateExecutionRegistry } from "./server/execution/matilda-execution-registry-validate.ts";
const r = validateExecutionRegistry();
if (!r.ok) throw new Error("registry validation failed");
console.log("REGISTRY_VALIDATOR=PASS");
'

echo
echo "=== TRANSITION TABLE ==="
npx tsx -e '
import fs from "fs";
import assert from "node:assert/strict";
import { buildTransitionTable } from "./server/execution/matilda-execution-transition-table.ts";
const r = JSON.parse(fs.readFileSync(
  "docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json",
  "utf8"
));
assert.deepEqual(
  buildTransitionTable(),
  r.execution_state_model.transitions
);
console.log("TRANSITION_TABLE=PASS");
'

echo
echo "=== EXECUTION SWITCH ==="
npx tsx -e '
import assert from "node:assert/strict";
import { evaluateExecutionSwitch } from "./server/execution/matilda-execution-switch-evaluator.ts";

const cases = [
  [{
    current_state: "DISABLED",
    execution_authorized: false,
    preview_confirmed: false,
    execution_plan_status: "draft"
  }, "DISABLED"],
  [{
    current_state: "DISABLED",
    execution_authorized: true,
    preview_confirmed: false,
    execution_plan_status: "draft"
  }, "ARMED"],
  [{
    current_state: "ARMED",
    execution_authorized: true,
    preview_confirmed: true,
    execution_plan_status: "draft"
  }, "READY"],
  [{
    current_state: "READY",
    execution_authorized: true,
    preview_confirmed: true,
    execution_plan_status: "plan_review_ready"
  }, "EXECUTABLE"]
];

for (const [input, expected] of cases) {
  assert.equal(evaluateExecutionSwitch(input).state, expected);
}

console.log("EXECUTION_SWITCH=PASS");
'

echo
echo "=== VERIFY NO PROHIBITED AUTHORITY INTRODUCED ==="
if git diff -U0 -- "${AUTHORIZED_FILES[@]}" \
  | grep -E '^\+.*(execFile|execSync|spawn|git add|git commit|git push|shell_execution_authorized)' ; then
  echo "STOP: prohibited runtime authority introduced"
  exit 1
fi
echo "AUTHORITY_BOUNDARY=PASS"

echo
echo "=== STAGE ONLY AUTHORIZED FILES ==="
git add "${AUTHORIZED_FILES[@]}"

EXPECTED="$(
  printf '%s\n' "${AUTHORIZED_FILES[@]}" | sort
)"
ACTUAL="$(
  git diff --cached --name-only | sort
)"

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set does not equal authorized repair set"
  git reset
  exit 1
fi

echo
echo "=== COMMIT ISOLATED REPAIR ==="
git commit -m "Repair canonical execution registry integrity"
git push

echo
echo "REGISTRY_INTEGRITY_REPAIR=COMMITTED_AND_PUSHED"
echo "CADE_VERSION_CONTROL_CONTRACT_WORK=REMAINS_UNCOMMITTED"
echo "NEXT_ACTION=RESUME_CADE_VERSION_CONTROL_CONTRACT_VALIDATION"
