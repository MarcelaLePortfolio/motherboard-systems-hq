#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== AUTHORIZE CADE VERSION CONTROL CONTRACT-ONLY IMPLEMENTATION UNIT ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION_SCOPE=CONTRACT_VALIDATION_APPROVAL_SEMANTICS_ONLY"
echo "GIT_SIDE_EFFECTS=PROHIBITED"
echo "REMOTE_WRITE=PROHIBITED"
echo "CADE_EXECUTOR_CHANGE=PROHIBITED"

EXPECTED_HEAD_PREFIX="4104c7471"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== AUTHORIZED PATCH SET ==="
echo "1 server/contracts/execution-envelope.v1.mjs"
echo "2 server/execution/build-execution-envelope-draft.mjs"
echo "3 server/execution/build-approval-artifact.mjs"
echo "4 server/execution/execution-approval-gate.mjs"
echo "5 server/guards/validate-execution-envelope.mjs"
echo "6 server/execution/governance-validator.mjs"
echo "7 server/execution/smoke-test-version-control-contract.mjs"
echo
echo "=== REQUIRED SEMANTICS ==="
echo "project_target.expected_head optional for ordinary planning"
echo "project_target.expected_head required only by future version-control execution"
echo "version_control_authorization.commit_authorized defaults false"
echo "version_control_authorization.push_authorized defaults false"
echo "version_control_authorization.remote defaults origin"
echo "version_control_authorization.branch defaults null"
echo "commit authorization does not imply push"
echo "version-control authorization does not imply mutation"
echo "version-control authorization does not imply shell execution"
echo "planning-only pipeline remains planning-only"

echo
echo "=== REQUIRED VALIDATION ==="
echo "ordinary planning envelope without expected_head remains valid"
echo "well-formed expected_head is preserved"
echo "malformed expected_head fails closed"
echo "commit authorization defaults false"
echo "push authorization defaults false"
echo "commit true does not imply push true"
echo "version-control authorization does not enable mutation"
echo "version-control authorization does not enable shell"
echo "governed planning pipeline remains non-mutating"
echo "no git command executes"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "ANY_PLANNING_REGRESSION=REVERT"
echo "ANY_AUTHORITY_ESCALATION=REVERT"
echo "ANY_GIT_SIDE_EFFECT=REVERT"
echo "THREE_FAILED_HYPOTHESIS_RULE=ACTIVE"

echo
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "NEXT_ACTION=APPLY_EXACT_CONTRACT_ONLY_PATCH"
