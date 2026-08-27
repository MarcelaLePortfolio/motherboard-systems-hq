#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE CADE CONTRACT THROUGH COMPILED RUNTIME ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION=EXISTING_CONTRACT_ONLY_UNIT"
echo "APPROVAL_GATE_IMPORT_CHANGE=NO"
echo "RUNTIME_GIT_SIDE_EFFECTS=PROHIBITED"

EXPECTED_HEAD_PREFIX="d8b443889"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

CONTRACT_FILES=(
  server/contracts/execution-envelope.v1.mjs
  server/execution/build-approval-artifact.mjs
  server/execution/build-execution-envelope-draft.mjs
  server/execution/execution-approval-gate.mjs
  server/guards/validate-execution-envelope.mjs
  server/execution/smoke-test-version-control-contract.mjs
)

echo
echo "=== VERIFY CONTRACT WORKTREE PRESENT ==="
for f in "${CONTRACT_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "STOP: missing $f"
    exit 1
  fi
  echo "PRESENT=$f"
done

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== BUILD COMPILED RUNTIME ==="
npm run build

echo
echo "=== VERIFY COMPILED EXECUTION SWITCH EXISTS ==="
test -f dist/server/execution/matilda-execution-switch-evaluator.js
test -f dist/server/execution/matilda-execution-registry-loader.js
echo "COMPILED_EXECUTION_SWITCH=PASS"

echo
echo "=== RUN SOURCE-SAFE CONTRACT ASSERTIONS ==="
npx tsx server/execution/smoke-test-version-control-contract.mjs

echo
echo "=== RUN EXISTING SOURCE-SAFE ENVELOPE SMOKE ==="
node server/execution/smoke-test-envelope-draft.mjs

echo
echo "=== VERIFY APPROVAL GATE CONTRACT SEMANTICS DIRECTLY ==="
npx tsx -e '
import fs from "fs";
import assert from "node:assert/strict";

const approvalSource = fs.readFileSync(
  "server/execution/build-approval-artifact.mjs",
  "utf8"
);
const gateSource = fs.readFileSync(
  "server/execution/execution-approval-gate.mjs",
  "utf8"
);

assert.match(
  approvalSource,
  /version_control_authorization/
);
assert.match(
  approvalSource,
  /commit_authorized/
);
assert.match(
  approvalSource,
  /push_authorized/
);
assert.match(
  gateSource,
  /execution_phase:\s*"governed_planning_only"/
);
assert.doesNotMatch(
  gateSource,
  /shell_execution_authorized:\s*true/
);

console.log("APPROVAL_GATE_CONTRACT=PASS");
'

echo
echo "=== VERIFY EXPECTED HEAD CONTRACT ==="
npx tsx -e '
import fs from "fs";
import assert from "node:assert/strict";

const envelope = fs.readFileSync(
  "server/contracts/execution-envelope.v1.mjs",
  "utf8"
);
const draft = fs.readFileSync(
  "server/execution/build-execution-envelope-draft.mjs",
  "utf8"
);
const validator = fs.readFileSync(
  "server/guards/validate-execution-envelope.mjs",
  "utf8"
);

assert.match(envelope, /expected_head/);
assert.match(draft, /expected_head/);
assert.match(validator, /project_target\.expected_head/);

console.log("EXPECTED_HEAD_CONTRACT=PASS");
'

echo
echo "=== VERIFY NO RUNTIME GIT EFFECT INTRODUCED ==="
if git diff -U0 -- "${CONTRACT_FILES[@]}" \
  | grep -E '^\+.*(execFile|execSync|spawn|git add|git commit|git push|force-with-lease|--force)' ; then
  echo "STOP: runtime Git/process execution introduced"
  exit 1
fi
echo "RUNTIME_GIT_EFFECT=NONE"

echo
echo "=== STAGE ONLY AUTHORIZED CONTRACT FILES ==="
git add "${CONTRACT_FILES[@]}"

EXPECTED="$(
  printf '%s\n' "${CONTRACT_FILES[@]}" | sort
)"
ACTUAL="$(
  git diff --cached --name-only | sort
)"

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set does not equal contract unit"
  git reset
  exit 1
fi

echo
echo "=== COMMIT CONTRACT UNIT ==="
git commit -m "Add Cade version control contract semantics"
git push

echo
echo "CADE_VERSION_CONTROL_CONTRACT_UNIT=COMMITTED_AND_PUSHED"
echo "CADE_GIT_EXECUTION_CAPABILITY=NOT_YET_ENABLED"
echo "NEXT_ACTION=CLASSIFY_BOUNDED_GIT_EFFECT_IMPLEMENTATION_UNIT"
