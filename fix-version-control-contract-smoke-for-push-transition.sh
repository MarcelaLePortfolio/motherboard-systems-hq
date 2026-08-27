#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX VERSION CONTROL CONTRACT SMOKE FOR PUSH TRANSITION ==="
echo "MODE=EXECUTION"
echo "HYPOTHESIS=PUSH_APPROVAL_GATE_IMPLEMENTATION_REMAINS_VALID"
echo "FAILURE_CLASS=LEGACY_SMOKE_EXPECTATION_MISMATCH"
echo "REMOTE_PUSH_EFFECT_IMPLEMENTATION_AUTHORIZED=NO"
echo "REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="03ce1a2dd"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("server/execution/smoke-test-version-control-contract.mjs")
text = path.read_text()

old = '''assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: governedCommitEnvelope,
      governance: governedCommitGovernance,
      approval: approvedCommitArtifact({
        version_control_authorization: {
          commit_authorized: true,
          push_authorized: true,
          remote: "origin",
          branch:
            "feature/support-source-references-runtime",
        },
      }),
    }),
  /push authority remains disabled/,
);
'''

new = '''assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: governedCommitEnvelope,
      governance: governedCommitGovernance,
      approval: approvedCommitArtifact({
        version_control_authorization: {
          commit_authorized: true,
          push_authorized: true,
          remote: "origin",
          branch:
            "feature/support-source-references-runtime",
        },
      }),
    }),
  /successful local commit result/,
);
'''

if old not in text:
    raise SystemExit(
        "STOP: expected legacy push smoke assertion not found"
    )

path.write_text(text.replace(old, new, 1))
PY

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== EXISTING VERSION CONTROL CONTRACT SMOKE ==="
npx tsx server/execution/smoke-test-version-control-contract.mjs
echo "VERSION_CONTROL_CONTRACT_SMOKE=PASS"

echo
echo "=== PUSH APPROVAL TRANSITION SMOKE ==="
npx tsx server/execution/smoke-test-version-control-push-approval.mjs
echo "PUSH_APPROVAL_SMOKE=PASS"

echo
echo "=== VERIFY NO PUSH EFFECT / PROCESS EFFECT IN APPROVAL UNIT ==="
node - <<'NODE'
const fs = require("fs");

const files = [
  "server/execution/execution-approval-gate.mjs",
  "server/execution/smoke-test-version-control-contract.mjs",
  "server/execution/smoke-test-version-control-push-approval.mjs",
];

const prohibited = [
  /node:child_process/,
  /\bexecFile(?:Sync)?\s*\(/,
  /\bexec(?:Sync)?\s*\(/,
  /\bspawn(?:Sync)?\s*\(/,
  /\bgit\s+push\b/,
];

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");

  for (const pattern of prohibited) {
    if (pattern.test(source)) {
      throw new Error(
        `prohibited process or push effect in ${file}`,
      );
    }
  }
}

console.log("APPROVAL_UNIT_SIDE_EFFECTS=NONE");
NODE

echo
echo "=== VERIFY PROTECTED SURFACES UNCHANGED ==="
if git diff -- \
  server/cade/cade-version-control-effects.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  | grep -q .; then
  echo "STOP: prohibited surface changed"
  exit 1
fi

echo "PROTECTED_SURFACES_UNCHANGED=YES"

AUTHORIZED_FILES=(
  server/execution/execution-approval-gate.mjs
  server/execution/smoke-test-version-control-contract.mjs
  server/execution/smoke-test-version-control-push-approval.mjs
)

if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi

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
  echo "STOP: staged set exceeds authorized push approval unit"
  git restore --staged -- "${AUTHORIZED_FILES[@]}"
  exit 1
fi

git commit -m "Enable narrow governed Cade push approval"
git push

echo
echo "NARROW_PUSH_APPROVAL_TRANSITION=COMMITTED_AND_PUSHED"
echo "REMOTE_PUSH_EFFECT=NOT_IMPLEMENTED"
echo "REMOTE_PUSH_EXECUTION=NOT_ENABLED"
echo "NEXT_ACTION=VALIDATE_AND_CLOSE_PUSH_APPROVAL_TRANSITION_BEFORE_PUSH_EFFECT_AUTHORIZATION"
