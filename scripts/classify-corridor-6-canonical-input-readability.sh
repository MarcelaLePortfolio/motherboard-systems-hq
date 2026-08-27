#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="4a8c55c102a908dc4a4430e7e6ec3264e11bc3a6"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — CANONICAL INPUT READABILITY CLASSIFICATION ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "RECOVERY_POINT=DR_20260827_140611"
echo

echo "=== CURRENT EVIDENCE ==="
echo "LEGACY_DIAGNOSTIC_AUTHORITY_GATE_CANONICAL=NO"
echo "LEGACY_DIAGNOSTIC_AUTHORITY_GATE_FORBIDDEN_FOR_CORRIDOR_6=YES"
echo "MATILDA_EXECUTION_AUTHORIZATION_OBJECT_PRODUCER_EXISTS=YES"
echo "MATILDA_EXECUTION_AUTHORIZATION_DURABLE_STORAGE_ESTABLISHED=NO"
echo "CANONICAL_GOVERNANCE_DELEGATION_AUTHORIZATION_TIMESTAMP_EXISTS=YES"
echo "DELEGATION_AUTHORIZATION_IS_NOT_USER_EXECUTION_AUTHORIZATION=YES"
echo

echo "=== APPROVAL REQUEST REPOSITORY ==="
sed -n '1,260p' db/approval-request-repository.ts 2>/dev/null || true
echo

echo "=== APPROVAL REQUEST MODEL ASSEMBLER ==="
sed -n '1,260p' db/approval-request-model-assembler.ts 2>/dev/null || true
echo

echo "=== CANONICAL PACKAGE RUNTIME READ SURFACES ==="
git grep -n -E \
'export function (get|find|read|list).*Package|SELECT .*canonical|FROM .*canonical|package_id.*WHERE|WHERE.*package_id' \
-- db/matilda-canonical-package-runtime.ts db server routes ':!**/*.test.ts' || true
echo

echo "=== GOVERNANCE RUNTIME ENVELOPE SCHEMA ==="
sed -n '180,360p' db/governance-runtime.ts
echo

echo "=== GOVERNANCE RUNTIME ENVELOPE CREATE / READ FUNCTIONS ==="
git grep -n -E \
'export function|function .*Envelope|createGovernanceEnvelope|listGovernanceEnvelope|getGovernanceEnvelope|findGovernanceEnvelope|SELECT|FROM governance_' \
-- db/governance-runtime.ts || true
echo

echo "=== EXECUTION APPROVAL PRODUCER FALSIFICATION ==="
git grep -n -E \
'status:[[:space:]]*"approved"|status[[:space:]]*=[[:space:]]*"approved"|approved_by|approval_id.*status|version_control_authorization' \
-- \
db server routes \
':!server/execution/smoke-test-*' \
':!server/execution/build-approval-artifact.mjs' \
':!**/*.test.ts' \
|| true
echo

echo "=== USER AUTHORIZATION DURABILITY FALSIFICATION ==="
git grep -n -E \
'CREATE TABLE.*execution.*authorization|INSERT INTO.*execution.*authorization|SELECT .*execution.*authorization|authorization_id.*PRIMARY|authorization_id.*TEXT' \
-- \
db server routes migrations \
':!**/*.test.ts' \
|| true
echo

echo "=== ENVELOPE READER FALSIFICATION ==="
git grep -n -E \
'SELECT .*governance_envelope|FROM governance_envelope|FROM governance_envelopes|WHERE envelope_id|WHERE package_id' \
-- \
db server routes \
':!**/*.test.ts' \
|| true
echo

echo "=== EXECUTION ID CLASSIFICATION ==="
git grep -n -E \
'executionId:[[:space:]]*string|requires execution_id|executionId,' \
-- \
server/execution/production-execution-entry-point.ts \
server/execution/cade-governed-commit-adapter.ts \
server/execution/cade-governed-push-adapter.ts
echo
echo "EXECUTION_ID_CURRENT_CONTRACT=CALLER_SUPPLIED"
echo

echo "=== CLASSIFICATION ==="
echo "INPUT_A_DURABLE_USER_EXECUTION_AUTHORIZATION=NOT_YET_READABLE_BY_ESTABLISHED_PRODUCTION_READER"
echo "INPUT_B_APPROVED_EXECUTION_APPROVAL=PRODUCTION_PRODUCER_NOT_YET_ESTABLISHED"
echo "INPUT_C_CANONICAL_EXECUTION_ENVELOPE=AUTHORITATIVE_PERSISTENCE_EXISTS_BUT_READABILITY_REQUIRES_EXACT_CONFIRMATION"
echo "INPUT_D_EXECUTION_ID=CALLER_SUPPLIED"
echo

echo "=== SAFETY DETERMINATION ==="
echo "DEDICATED_EXECUTION_ROUTE_IMPLEMENTATION_READY=NO"
echo "REASON=AUTHORITATIVE_AUTHORIZATION_AND_APPROVAL_INPUTS_NOT_YET_RESOLVED"
echo "DO_NOT_USE_LEGACY_AUTHORITY_GATE=YES"
echo "DO_NOT_TREAT_DELEGATION_AUTHORIZATION_AS_USER_EXECUTION_AUTHORIZATION=YES"
echo "DO_NOT_CREATE_APPROVED_EXECUTION_ARTIFACT=YES"
echo "DO_NOT_CREATE_PARALLEL_AUTHORIZATION_MODEL=YES"
echo

echo "=== NEXT INVESTIGATION ==="
echo "NEXT_TARGET_1=RECONCILE_CORRIDOR_2_CURRENT_USER_MESSAGE_DURABILITY_WITH_RUNTIME_READ_SURFACES"
echo "NEXT_TARGET_2=IDENTIFY_CANONICAL_EXECUTION_APPROVAL_TRANSITION_OR_CONFIRM_ABSENCE"
echo "NEXT_TARGET_3=CONFIRM_EXACT_CANONICAL_ENVELOPE_READER"
echo

echo "=== STOP POINT ==="
echo "CORRIDOR_6=SELF_IMPROVEMENT_EXECUTION_ACTIVATION_CLOSURE"
echo "CORRIDOR_6_STATUS=OPEN_CANONICAL_INPUT_GAPS"
echo "PHASE_1_STATUS=ACTIVE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "NO_IMPLEMENTATION_PERFORMED=YES"
echo "NEXT_ACTION=RECONCILE_CANONICAL_USER_AUTHORIZATION_APPROVAL_TRANSITION_AND_ENVELOPE_READER"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
