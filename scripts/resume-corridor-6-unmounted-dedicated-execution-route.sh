#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="ab0e3ddc4"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — RESUME UNMOUNTED DEDICATED EXECUTION ROUTE ==="
echo "MODE=EXECUTION"
echo "DURABILITY_UNIT_STATUS=CLOSED"
echo "DURABILITY_CLOSURE_COMMIT=ab0e3ddc4"
echo

echo "=== AUTHORIZATION CONTINUITY ==="
echo "UNMOUNTED_DEDICATED_EXECUTION_ROUTE_IMPLEMENTATION_AUTHORIZED=YES"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "GENERIC_CADE_AUTHORITY_AUTHORIZED=NO"
echo "GENERIC_SHELL_AUTHORITY_AUTHORIZED=NO"
echo "GENERIC_MUTATION_AUTHORITY_AUTHORIZED=NO"
echo "SCHEDULER_OR_AUTONOMY_AUTHORIZED=NO"
echo

echo "=== REQUIRED ROUTE COMPOSITION ==="
echo "STEP_1=LOAD_EXACT_DURABLE_EXECUTION_APPROVAL"
echo "STEP_2=LOAD_EXACT_DURABLE_EXECUTION_SCOPE"
echo "STEP_3=RECONSTRUCT_CANONICAL_EXECUTION_ENVELOPE_FROM_DURABLE_AUTHORITY"
echo "STEP_4=COMPILE_PERSISTED_APPROVAL_TO_EXISTING_GATE_SHAPE"
echo "STEP_5=BIND_EXISTING_EXECUTION_APPROVAL_EVALUATOR"
echo "STEP_6=CALL_EXISTING_BOUNDED_PRODUCTION_EXECUTION_ENTRY_POINT"
echo "STEP_7=RETURN_EXISTING_CORRELATED_COMMIT_AND_PUSH_PROOFS"
echo

echo "=== REQUIRED INPUT CONTRACT ==="
echo "INPUT_1=approval_id"
echo "INPUT_2=envelope_id"
echo "INPUT_3=execution_id"
echo "INPUT_4=commit_requested"
echo "INPUT_5=push_requested"
echo "INPUT_6=commit_message_WHEN_COMMIT_REQUESTED"
echo "INPUT_7=expected_remote_url_WHEN_PUSH_REQUESTED"
echo

echo "=== PROHIBITED CLIENT AUTHORITY INPUTS ==="
echo "CLIENT_APPROVED_BY=PROHIBITED"
echo "CLIENT_COMMIT_AUTHORIZED=PROHIBITED"
echo "CLIENT_PUSH_AUTHORIZED=PROHIBITED"
echo "CLIENT_PACKAGE_AUTHORITY=PROHIBITED"
echo "CLIENT_FULL_ENVELOPE_CONTENT=PROHIBITED"
echo "CLIENT_REPO_PATH_AUTHORITY=PROHIBITED"
echo "CLIENT_EXPECTED_HEAD_AUTHORITY=PROHIBITED"
echo "CLIENT_MUTATION_SCOPE_AUTHORITY=PROHIBITED"
echo

echo "=== PRE-IMPLEMENTATION SOURCE CHECK ==="
sed -n '1,420p' db/governance-execution-scope-persistence.ts
echo
sed -n '1,360p' db/governance-execution-approval-persistence.ts
echo
sed -n '1,320p' server/execution/compile-persisted-execution-approval.mjs
echo
sed -n '1,420p' server/execution/production-execution-entry-point.ts
echo
sed -n '1,360p' server/execution/execution-approval-gate.mjs
echo

echo "=== ROUTE BINDING SEARCH ==="
grep -RniE \
'createRouter|Router\\(|express\\.Router|router\\.post|executeProductionExecutionEntryPoint|evaluateExecutionApproval|loadGovernanceExecutionScope|loadGovernanceExecutionApproval' \
server/routes server/execution \
--exclude='*.test.*' \
--exclude='*.spec.*' \
| head -n 260 || true
echo

echo "=== IMPLEMENTATION GATE ==="
echo "UNMOUNTED_ROUTE_IMPLEMENTATION_MAY_PROCEED=YES"
echo "SERVER_INDEX_MUST_NOT_CHANGE=YES"
echo "ROUTE_MUST_REMAIN_UNMOUNTED=YES"
echo "REAL_GIT_EFFECTS_IN_TESTS=PROHIBITED"
echo "PRODUCTION_DB_IN_TESTS=PROHIBITED"
echo
echo "CORRIDOR_6_STATUS=UNMOUNTED_DEDICATED_EXECUTION_ROUTE_IMPLEMENTATION_RESUMED"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=IMPLEMENT_UNMOUNTED_DEDICATED_EXECUTION_ROUTE_AND_TARGETED_TESTS"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
