#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX CADE CONTRACT GIT-EFFECT SCAN AND COMMIT ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION=EXISTING_CONTRACT_ONLY_UNIT"
echo "RUNTIME_GIT_SIDE_EFFECTS=PROHIBITED"

EXPECTED_HEAD_PREFIX="22f3dea40"
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
echo "=== RECONFIRM VALIDATION ==="
npx tsc --noEmit
npx tsx server/execution/smoke-test-version-control-contract.mjs
node server/execution/smoke-test-envelope-draft.mjs

echo
echo "=== VERIFY ACTUAL PROHIBITED RUNTIME EFFECTS ONLY ==="
PROHIBITED_PATTERN='(execFile|execSync|spawn)\s*\(|(^|[^A-Za-z])git[[:space:]]+(add|commit|push)([^A-Za-z]|$)|--force-with-lease|(^|[^A-Za-z])--force([^A-Za-z]|$)'

MATCHES="$(
  git diff -U0 -- "${CONTRACT_FILES[@]}" \
    | grep '^+' \
    | grep -v '^+++' \
    | grep -E "${PROHIBITED_PATTERN}" \
    || true
)"

if [[ -n "${MATCHES}" ]]; then
  printf '%s\n' "${MATCHES}"
  echo "STOP: prohibited runtime Git/process execution introduced"
  exit 1
fi

echo "RUNTIME_GIT_EFFECT=NONE"

echo
echo "=== VERIFY EXPECTED_HEAD VALIDATION TEXT IS NOT MISCLASSIFIED ==="
grep -n \
  'project_target.expected_head must be a 40-character git commit SHA when supplied' \
  server/guards/validate-execution-envelope.mjs
echo "EXPECTED_HEAD_VALIDATION_TEXT=PASS"

echo
echo "=== VERIFY PLANNING-ONLY AUTHORITY ==="
grep -q 'execution_phase: "governed_planning_only"' \
  server/execution/execution-approval-gate.mjs
grep -q 'mutation_authorized: false' \
  server/execution/execution-approval-gate.mjs
grep -q 'shell_execution_authorized: false' \
  server/execution/execution-approval-gate.mjs
echo "PLANNING_ONLY_AUTHORITY=PASS"

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
