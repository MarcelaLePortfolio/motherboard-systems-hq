#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PRODUCTION REACHABILITY AND END-TO-END GOVERNED GIT FLOW ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"
echo "ACTIVE_PROJECT_LOCAL_COMMIT_EXECUTION_AUTHORIZED=NO"
echo "GENERIC_CADE_ROUTE_CHANGE=NO"

EXPECTED_HEAD_PREFIX="1c8972bd3"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CLOSED VERSION CONTROL UNITS ==="
echo "LOCAL_COMMIT_EFFECT_UNIT=CLOSED"
echo "LOCAL_COMMIT_CLOSURE_COMMIT=693d3c9f6"
echo "PUSH_APPROVAL_TRANSITION=CLOSED"
echo "PUSH_APPROVAL_CLOSURE_COMMIT=90248c230"
echo "REMOTE_PUSH_EFFECT_UNIT=CLOSED"
echo "REMOTE_PUSH_EFFECT_COMMIT=93d3fe06a"
echo "REMOTE_PUSH_EFFECT_CLOSURE_COMMIT=1c8972bd3"

echo
echo "=== CURRENT CAPABILITY STATE ==="
echo "LOCAL_COMMIT_EFFECT_IMPLEMENTED=YES"
echo "PUSH_APPROVAL_CAPABILITY_IMPLEMENTED=YES"
echo "REMOTE_PUSH_EFFECT_IMPLEMENTED=YES"
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"
echo "ACTIVE_PROJECT_END_TO_END_REACHABILITY=NOT_YET_ESTABLISHED"
echo "ACTIVE_PROJECT_REMOTE_PUSH_ENABLED=NO"

echo
echo "=== INSPECT GOVERNED ENTRYPOINT REACHABILITY ==="
git grep -n -I -E \
  'executeGovernedLocalCommit|executeGovernedRemotePush|performGovernedLocalCommit|performGovernedRemotePush|evaluateExecutionApproval' \
  -- \
  server routes \
  | sed -n '1,800p' || true

echo
echo "=== INSPECT APPROVAL LIFECYCLE / STATUS REACHABILITY ==="
git grep -n -I -E \
  'approval_required|status:[[:space:]]*"approved"|status:[[:space:]]*'\''approved'\''|approved_by|buildApprovalArtifact|approval_id|version_control_authorization' \
  -- \
  server routes \
  | sed -n '1,800p' || true

echo
echo "=== INSPECT GOVERNED PIPELINE / EXECUTION SWITCH CALLERS ==="
git grep -n -I -E \
  'governed-planning|governed_planning|execution-approval-gate|evaluateExecutionSwitch|execution_phase|governed_version_control_commit|governed_version_control_push' \
  -- \
  server routes \
  | sed -n '1,800p' || true

echo
echo "=== INSPECT CURRENT CADE GENERIC EXECUTION SURFACES ==="
for f in \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/orchestration/router.ts
do
  if [[ -f "${f}" ]]; then
    echo "--- ${f} ---"
    nl -ba "${f}" | sed -n '1,420p'
  fi
done

echo
echo "=== INSPECT GOVERNED VERSION CONTROL ADAPTERS ==="
for f in \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/cade-governed-push-adapter.ts \
  server/execution/execution-approval-gate.mjs \
  server/execution/build-approval-artifact.mjs
do
  if [[ -f "${f}" ]]; then
    echo "--- ${f} ---"
    nl -ba "${f}" | sed -n '1,520p'
  fi
done

echo
echo "=== END-TO-END FLOW THAT MUST EVENTUALLY BE PROVEN ==="
echo "STEP_1=USER_INTENT"
echo "STEP_2=MATILDA_INTERPRETATION"
echo "STEP_3=GOVERNED_ENVELOPE"
echo "STEP_4=EXPLICIT_APPROVAL_ARTIFACT"
echo "STEP_5=APPROVAL_GATE_COMMIT_PHASE"
echo "STEP_6=CADE_GOVERNED_LOCAL_COMMIT"
echo "STEP_7=LOCAL_COMMIT_RESULT_CORRELATION"
echo "STEP_8=APPROVAL_GATE_PUSH_PHASE"
echo "STEP_9=CADE_GOVERNED_REMOTE_PUSH"
echo "STEP_10=REMOTE_HEAD_VERIFICATION"
echo "STEP_11=EXECUTION_EVENT_PROVENANCE"
echo "STEP_12=USER_VISIBLE_RECONCILIATION"

echo
echo "=== REQUIRED PRODUCTION REACHABILITY QUESTIONS ==="
echo "Q1=WHAT_CANONICAL_RUNTIME_CALLER_OWNS_GOVERNED_LOCAL_COMMIT_ADAPTER"
echo "Q2=WHAT_CANONICAL_RUNTIME_CALLER_OWNS_GOVERNED_PUSH_ADAPTER"
echo "Q3=HOW_APPROVAL_REQUIRED_TRANSITIONS_TO_APPROVED"
echo "Q4=HOW_USER_APPROVAL_IS_BOUND_TO_APPROVAL_ID_AND_ENVELOPE_ID"
echo "Q5=HOW_LOCAL_COMMIT_RESULT_IS_TRANSPORTED_TO_PUSH_APPROVAL_GATE"
echo "Q6=HOW_EXECUTION_SWITCH_PARTICIPATES_WITHOUT_GENERIC_AUTHORITY_EXPANSION"
echo "Q7=HOW_ACTIVE_PROJECT_REPO_REMOTE_BRANCH_IDENTITY_IS_RESOLVED"
echo "Q8=HOW_REMOTE_URL_IDENTITY_IS_AUTHORIZED_FOR_PRODUCTION"
echo "Q9=HOW_END_TO_END_EXECUTION_REMAINS_UNREACHABLE_FROM_GENERIC_CADE_ROUTE"
echo "Q10=WHAT_EXPLICIT_USER_ACTION_AUTHORIZES_ACTIVE_REPOSITORY_EFFECTS"

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "EFFECT_IMPLEMENTATION_COMPLETE=YES"
echo "PRODUCTION_REACHABILITY_COMPLETE=NO"
echo "ACTIVE_REPOSITORY_ENABLEMENT_AUTHORIZED=NO"
echo "NO_RUNTIME_PATCH_AUTHORIZED_BY_THIS_CLASSIFICATION=YES"
echo "NEXT_ACTION=RETURN_REPOSITORY_EVIDENCE_AND_CLASSIFY_MINIMUM_PRODUCTION_REACHABILITY_UNIT"
