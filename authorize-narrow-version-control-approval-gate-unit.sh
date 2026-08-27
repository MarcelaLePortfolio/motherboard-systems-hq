#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== AUTHORIZE NARROW VERSION CONTROL APPROVAL GATE UNIT ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION_SCOPE=GOVERNED_LOCAL_COMMIT_APPROVAL_TRANSITION_ONLY"
echo "LOCAL_GIT_COMMIT_EFFECT_AUTHORIZED=NO"
echo "REMOTE_PUSH_EFFECT_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="0962a7281"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== AUTHORIZED PATCH SET ==="
echo "FILE_1=server/execution/execution-approval-gate.mjs"
echo "FILE_2=server/execution/smoke-test-version-control-contract.mjs"
echo "OPTIONAL_FILE_3=server/execution/smoke-test-version-control-approval-gate.mjs"

echo
echo "=== REQUIRED NEW APPROVAL PHASE ==="
echo "PHASE=governed_version_control_commit"
echo "SCOPE=LOCAL_COMMIT_AUTHORITY_ONLY"

echo
echo "=== REQUIRED GRANT CONDITIONS ==="
echo "GOVERNANCE_OK=true"
echo "DELEGATED_ENVELOPE=true"
echo "APPROVAL_PRESENT=true"
echo "REQUESTED_COMMIT_AUTHORIZED=true"
echo "REQUESTED_PUSH_AUTHORIZED=false"
echo "EXPECTED_HEAD_PRESENT=true"
echo "REPO_PATH_PRESENT=true"
echo "BRANCH_PRESENT=true"
echo "ALLOWED_PATHS_NONEMPTY=true"
echo "MUTATION_AUTHORIZED=false"
echo "SHELL_EXECUTION_AUTHORIZED=false"
echo "AUTONOMOUS_EXECUTION_AUTHORIZED=false"

echo
echo "=== REQUIRED EFFECTIVE OUTPUT ==="
echo "execution_phase=governed_version_control_commit"
echo "version_control_authorization.commit_authorized=true"
echo "version_control_authorization.push_authorized=false"
echo "mutation_authorized=false"
echo "shell_execution_authorized=false"
echo "autonomous_execution_authorized=false"

echo
echo "=== REQUIRED FAIL-CLOSED CASES ==="
echo "MISSING_EXPECTED_HEAD=BLOCK"
echo "MISSING_REPO_PATH=BLOCK"
echo "MISSING_BRANCH=BLOCK"
echo "EMPTY_ALLOWED_PATHS=BLOCK"
echo "UNDELEGATED_ENVELOPE=BLOCK"
echo "MISSING_APPROVAL=BLOCK"
echo "PUSH_AUTHORIZED_TRUE=BLOCK"
echo "GENERIC_MUTATION_TRUE=BLOCK"
echo "GENERIC_SHELL_TRUE=BLOCK"
echo "AUTONOMOUS_TRUE=BLOCK"
echo "GOVERNANCE_FAILURE=BLOCK"

echo
echo "=== REQUIRED TRACE ==="
echo "approval_artifact_normalized=YES"
echo "governance_validated=YES"
echo "delegation_validated=YES"
echo "version_control_commit_authority_granted=YES"
echo "push_authority_blocked=YES"
echo "mutation_authority_blocked=YES"
echo "shell_authority_blocked=YES"
echo "autonomous_authority_blocked=YES"

echo
echo "=== PRESERVED ARCHITECTURE ==="
echo "EXECUTION_SWITCH_CHANGE=PROHIBITED"
echo "GOVERNANCE_VALIDATOR_CHANGE=PROHIBITED"
echo "BUILD_APPROVAL_ARTIFACT_CHANGE=PROHIBITED"
echo "CADE_EXECUTOR_CHANGE=PROHIBITED"
echo "CADE_EFFECT_CHANGE=PROHIBITED"
echo "GENERIC_CADE_ROUTE_CHANGE=PROHIBITED"
echo "EVENT_SCHEMA_CHANGE=PROHIBITED"
echo "GIT_PROCESS_EXECUTION=PROHIBITED"
echo "REMOTE_WRITE=PROHIBITED"

echo
echo "=== REQUIRED TESTS ==="
echo "TEST_1=ORDINARY_PLANNING_REMAINS_governed_planning_only"
echo "TEST_2=ORDINARY_PLANNING_COMMIT_AUTHORIZED_REMAINS_false"
echo "TEST_3=VALID_GOVERNED_COMMIT_REQUEST_GRANTS_commit_authorized_true"
echo "TEST_4=VALID_GOVERNED_COMMIT_REQUEST_KEEPS_push_authorized_false"
echo "TEST_5=VALID_GOVERNED_COMMIT_REQUEST_KEEPS_mutation_authorized_false"
echo "TEST_6=VALID_GOVERNED_COMMIT_REQUEST_KEEPS_shell_execution_authorized_false"
echo "TEST_7=VALID_GOVERNED_COMMIT_REQUEST_KEEPS_autonomous_execution_authorized_false"
echo "TEST_8=MISSING_EXPECTED_HEAD_FAILS_CLOSED"
echo "TEST_9=EMPTY_ALLOWED_PATHS_FAILS_CLOSED"
echo "TEST_10=PUSH_REQUEST_FAILS_CLOSED"
echo "TEST_11=UNDELEGATED_REQUEST_FAILS_CLOSED"
echo "TEST_12=NO_GIT_PROCESS_EXECUTION"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "ANY_PLANNING_REGRESSION=REVERT"
echo "ANY_PUSH_AUTHORITY_GRANT=REVERT"
echo "ANY_GENERIC_MUTATION_AUTHORITY_GRANT=REVERT"
echo "ANY_SHELL_AUTHORITY_GRANT=REVERT"
echo "ANY_AUTONOMOUS_AUTHORITY_GRANT=REVERT"
echo "ANY_GIT_EFFECT=REVERT"
echo "THREE_FAILED_HYPOTHESIS_RULE=ACTIVE"

echo
echo "=== AUTHORIZATION ==="
echo "NARROW_APPROVAL_GATE_COMMIT_AUTHORITY_UNIT_AUTHORIZED=YES"
echo "LOCAL_COMMIT_EFFECT_AUTHORIZED=NO"
echo "PUSH_EFFECT_AUTHORIZED=NO"
echo "NEXT_ACTION=IMPLEMENT_AND_VALIDATE_NARROW_APPROVAL_GATE_UNIT_ONLY"
