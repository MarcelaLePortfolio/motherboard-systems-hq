#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX NARROW APPROVAL GATE SMOKE BOUNDARY ==="
echo "MODE=EXECUTION"
echo "HYPOTHESIS=APPROVAL_GATE_IMPLEMENTATION_REMAINS_VALID"
echo "FAILURE_CLASS=SMOKE_FIXTURE_BOUNDARY_MISMATCH"
echo "APPROVAL_GATE_EDIT=NO"
echo "SMOKE_EDIT=YES"
echo "LOCAL_GIT_COMMIT_EFFECT_AUTHORIZED=NO"
echo "REMOTE_PUSH_EFFECT_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="2b151126f"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("server/execution/smoke-test-version-control-contract.mjs")
text = path.read_text()

old = '''const noAllowedPathsGovernance =
  validateGovernedExecutionEnvelope(
    noAllowedPathsEnvelope,
  );

const noAllowedPaths =
  evaluateExecutionApproval({
    envelope: noAllowedPathsEnvelope,
    governance: noAllowedPathsGovernance,
    approval: approvedCommitArtifact(),
  });
'''

new = '''assert.throws(
  () =>
    validateGovernedExecutionEnvelope(
      noAllowedPathsEnvelope,
    ),
  /allowed_paths required/,
);

const noAllowedPaths =
  evaluateExecutionApproval({
    envelope: noAllowedPathsEnvelope,
    governance: {
      ok: true,
    },
    approval: approvedCommitArtifact(),
  });
'''

if old not in text:
    raise SystemExit("STOP: expected noAllowedPaths smoke block not found")

path.write_text(text.replace(old, new))
PY

echo
echo "=== VALIDATE AUTHORIZED UNIT ==="
npx tsc --noEmit
npx tsx server/execution/smoke-test-version-control-contract.mjs

echo
echo "=== VERIFY APPROVAL GATE STILL ONLY AUTHORIZED RUNTIME CHANGE ==="
git diff --name-only

echo
echo "=== VERIFY NO PROCESS OR GIT EFFECTS ==="
node - <<'NODE'
const fs = require("fs");

const files = [
  "server/execution/execution-approval-gate.mjs",
  "server/execution/smoke-test-version-control-contract.mjs",
];

const prohibited = [
  /node:child_process/,
  /child_process/,
  /\bexecFile(?:Sync)?\s*\(/,
  /\bexec(?:Sync)?\s*\(/,
  /\bspawn(?:Sync)?\s*\(/,
];

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");

  for (const pattern of prohibited) {
    if (pattern.test(source)) {
      throw new Error(
        `prohibited process effect in ${file}`,
      );
    }
  }
}

console.log("PROCESS_EFFECTS=NONE");
NODE

echo
echo "=== STAGE ONLY AUTHORIZED APPROVAL UNIT ==="
git add \
  server/execution/execution-approval-gate.mjs \
  server/execution/smoke-test-version-control-contract.mjs

EXPECTED="$(
  printf '%s\n' \
    server/execution/execution-approval-gate.mjs \
    server/execution/smoke-test-version-control-contract.mjs \
  | sort
)"

ACTUAL="$(
  git diff --cached --name-only | sort
)"

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set exceeds authorized approval unit"
  git reset
  exit 1
fi

git commit -m "Enable narrow governed Cade commit approval"
git push

echo
echo "NARROW_COMMIT_APPROVAL_UNIT=COMMITTED_AND_PUSHED"
echo "LOCAL_GIT_COMMIT_EFFECT=NOT_YET_ENABLED"
echo "PUSH_EFFECT=NOT_ENABLED"
echo "NEXT_ACTION=VALIDATE_APPROVAL_UNIT_CLOSURE_AND_CLASSIFY_LOCAL_COMMIT_EFFECT_IMPLEMENTATION"
