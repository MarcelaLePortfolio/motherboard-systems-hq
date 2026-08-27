#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE CADE CONTRACT WITH STRUCTURAL EFFECT SCAN ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION=EXISTING_CONTRACT_ONLY_UNIT"
echo "FAILED_SCAN_HYPOTHESES=2"
echo "RUNTIME_GIT_SIDE_EFFECTS=PROHIBITED"

EXPECTED_HEAD_PREFIX="b8af50bb1"
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
echo "=== RECONFIRM CONTRACT VALIDATION ==="
npx tsc --noEmit
npx tsx server/execution/smoke-test-version-control-contract.mjs
node server/execution/smoke-test-envelope-draft.mjs
echo "CONTRACT_VALIDATION=PASS"

echo
echo "=== STRUCTURAL PROCESS-EFFECT SCAN ==="
node - "${CONTRACT_FILES[@]}" <<'NODE'
const fs = require("fs");

const files = process.argv.slice(2);

const prohibited = [
  {
    name: "child_process_import",
    re: /(?:from\s+["']node:child_process["']|from\s+["']child_process["']|require\s*\(\s*["'](?:node:)?child_process["']\s*\))/,
  },
  {
    name: "execfile_call",
    re: /\bexecFile(?:Sync)?\s*\(/,
  },
  {
    name: "exec_call",
    re: /\bexec(?:Sync)?\s*\(/,
  },
  {
    name: "spawn_call",
    re: /\bspawn(?:Sync)?\s*\(/,
  },
];

let failed = false;

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");

  for (const rule of prohibited) {
    if (rule.re.test(source)) {
      console.error(
        `PROHIBITED_EFFECT=${rule.name} FILE=${file}`
      );
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("STRUCTURAL_PROCESS_EFFECT_SCAN=PASS");
NODE

echo
echo "=== VERIFY CONTRACT AUTHORITY BOUNDARIES ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const gate = fs.readFileSync(
  "server/execution/execution-approval-gate.mjs",
  "utf8"
);
const approval = fs.readFileSync(
  "server/execution/build-approval-artifact.mjs",
  "utf8"
);
const validator = fs.readFileSync(
  "server/guards/validate-execution-envelope.mjs",
  "utf8"
);

assert.match(
  gate,
  /execution_phase:\s*"governed_planning_only"/
);
assert.match(
  gate,
  /mutation_authorized:\s*false/
);
assert.match(
  gate,
  /shell_execution_authorized:\s*false/
);
assert.match(
  approval,
  /version_control_authorization/
);
assert.match(
  approval,
  /commit_authorized/
);
assert.match(
  approval,
  /push_authorized/
);
assert.match(
  validator,
  /project_target\.expected_head/
);

console.log("CONTRACT_AUTHORITY_BOUNDARIES=PASS");
NODE

echo
echo "=== VERIFY NO CONTRACT FILE IS ALREADY STAGED ==="
if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi
echo "PREEXISTING_STAGED_SET=EMPTY"

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
  echo "STOP: staged set does not equal authorized contract unit"
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
