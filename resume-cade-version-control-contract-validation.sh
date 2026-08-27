#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RESUME CADE VERSION CONTROL CONTRACT VALIDATION ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION=EXISTING_CONTRACT_ONLY_UNIT"
echo "REGISTRY_REPAIR=COMPLETE"
echo "RUNTIME_GIT_SIDE_EFFECTS=PROHIBITED"

EXPECTED_HEAD_PREFIX="88f813981"
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
echo "=== VERIFY PRESERVED CONTRACT WORKTREE ==="
for f in "${CONTRACT_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    if git diff --quiet -- "$f" && git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      echo "UNCHANGED_TRACKED=$f"
    else
      echo "PRESENT_CHANGE=$f"
    fi
  else
    echo "STOP: expected contract file missing: $f"
    exit 1
  fi
done

echo
echo "=== TYPESCRIPT VALIDATION ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== EXISTING PLANNING SMOKES ==="
node server/execution/smoke-test-envelope-draft.mjs
node server/execution/smoke-test-approval-gate.mjs
node server/execution/smoke-test-governed-planning-pipeline.mjs

echo
echo "=== VERSION CONTROL CONTRACT SMOKE ==="
node server/execution/smoke-test-version-control-contract.mjs

echo
echo "=== VERIFY CONTRACT SEMANTICS ==="
node - <<'NODE'
const fs = require("fs");

const envelope = fs.readFileSync(
  "server/contracts/execution-envelope.v1.mjs",
  "utf8"
);
const draft = fs.readFileSync(
  "server/execution/build-execution-envelope-draft.mjs",
  "utf8"
);
const approval = fs.readFileSync(
  "server/execution/build-approval-artifact.mjs",
  "utf8"
);
const gate = fs.readFileSync(
  "server/execution/execution-approval-gate.mjs",
  "utf8"
);
const validator = fs.readFileSync(
  "server/guards/validate-execution-envelope.mjs",
  "utf8"
);

const checks = {
  envelope_expected_head:
    envelope.includes("expected_head"),
  draft_expected_head:
    draft.includes("expected_head"),
  approval_vc_subcontract:
    approval.includes("version_control_authorization"),
  commit_default_false:
    approval.includes("commit_authorized"),
  push_default_false:
    approval.includes("push_authorized"),
  gate_vc_subcontract:
    gate.includes("version_control_authorization"),
  validator_expected_head:
    validator.includes("project_target.expected_head"),
};

for (const [name, value] of Object.entries(checks)) {
  console.log(`${name.toUpperCase()}=${value ? "YES" : "NO"}`);
  if (!value) process.exitCode = 1;
}
NODE

echo
echo "=== VERIFY AUTHORITY BOUNDARY ==="
if git diff -U0 -- "${CONTRACT_FILES[@]}" \
  | grep -E '^\+.*(execFile|execSync|spawn|git add|git commit|git push|force-with-lease|--force)' ; then
  echo "STOP: prohibited runtime Git/process execution introduced"
  exit 1
fi

if ! grep -q 'execution_phase: "governed_planning_only"' \
  server/execution/execution-approval-gate.mjs; then
  echo "STOP: planning-only approval boundary missing"
  exit 1
fi

echo "AUTHORITY_BOUNDARY=PASS"

echo
echo "=== STAGE ONLY CONTRACT UNIT FILES ==="
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
echo "=== COMMIT CONTRACT-ONLY UNIT ==="
git commit -m "Add Cade version control contract semantics"
git push

echo
echo "CADE_VERSION_CONTROL_CONTRACT_UNIT=COMMITTED_AND_PUSHED"
echo "CADE_GIT_EXECUTION_CAPABILITY=NOT_YET_ENABLED"
echo "NEXT_ACTION=CLASSIFY_BOUNDED_GIT_EFFECT_IMPLEMENTATION_UNIT"
