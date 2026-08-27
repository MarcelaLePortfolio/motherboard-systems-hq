#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT ACTIVE FILES FOR FIRST CADE VERSION CONTROL IMPLEMENTATION UNIT ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="7beda24b6"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== TARGET UNIT ==="
echo "UNIT=CONTRACT_VALIDATION_APPROVAL_SEMANTICS_ONLY"
echo "GIT_SIDE_EFFECTS=NO"
echo "CADE_EXECUTOR_ACTIONS=NO"
echo "BOUNDED_GIT_EFFECT=NO"

echo
echo "=== RUNTIME ENVELOPE CONTRACT ==="
nl -ba server/contracts/execution-envelope.v1.mjs | sed -n '1,390p'

echo
echo "=== CANONICAL ENVELOPE DOCUMENTATION ==="
nl -ba docs/contracts/CANONICAL_EXECUTION_ENVELOPE_SCHEMA.md | sed -n '190,370p'

echo
echo "=== ENVELOPE DRAFT BUILDER ==="
nl -ba server/execution/build-execution-envelope-draft.mjs | sed -n '1,280p'

echo
echo "=== STRUCTURAL ENVELOPE VALIDATOR ==="
nl -ba server/guards/validate-execution-envelope.mjs | sed -n '1,260p'

echo
echo "=== GOVERNANCE VALIDATOR ==="
nl -ba server/execution/governance-validator.mjs | sed -n '1,300p'

echo
echo "=== APPROVAL ARTIFACT BUILDER ==="
nl -ba server/execution/build-approval-artifact.mjs | sed -n '1,180p'

echo
echo "=== APPROVAL GATE ==="
nl -ba server/execution/execution-approval-gate.mjs | sed -n '1,240p'

echo
echo "=== EXISTING ENVELOPE / APPROVAL TEST SURFACES ==="
for f in \
  server/execution/smoke-test-envelope-draft.mjs \
  server/execution/smoke-test-approval-gate.mjs \
  server/execution/smoke-test-governed-planning-pipeline.mjs \
  docs/contracts/EXECUTION_ENVELOPE_VALIDATION_SMOKE.md \
  docs/contracts/EXECUTION_APPROVAL_GATE_SMOKE.md
do
  if [[ -f "$f" ]]; then
    echo
    echo "--- $f ---"
    nl -ba "$f" | sed -n '1,320p'
  fi
done

echo
echo "=== SEARCH EXACT CONSTRUCTION / VALIDATION CALLERS ==="
git grep -n -I -E \
  'createExecutionEnvelope|buildExecutionEnvelopeDraft|validateExecutionEnvelope|validateGovernedExecutionEnvelope|buildApprovalArtifact|evaluateExecutionApproval' \
  -- server routes app src lib packages \
  | sed -n '1,720p' || true

echo
echo "=== FIRST IMPLEMENTATION UNIT BOUNDARY ==="
echo "ADD_PROJECT_TARGET_EXPECTED_HEAD=YES"
echo "ADD_VERSION_CONTROL_AUTHORIZATION_SUBCONTRACT=YES"
echo "DEFAULT_COMMIT_AUTHORIZED=false"
echo "DEFAULT_PUSH_AUTHORIZED=false"
echo "PRESERVE_PLANNING_ONLY_DEFAULT=YES"
echo "GENERIC_MUTATION_AUTHORITY_CHANGE=NO"
echo "GENERIC_SHELL_AUTHORITY_CHANGE=NO"
echo "AUTONOMOUS_AUTHORITY_CHANGE=NO"
echo "GIT_PROCESS_EXECUTION_CHANGE=NO"
echo "CADE_EXECUTOR_CHANGE=NO"

echo
echo "=== REQUIRED FAIL-CLOSED TESTS FOR UNIT ==="
echo "TEST_1=VERSION_CONTROL_REQUEST_WITHOUT_EXPECTED_HEAD_REJECTED"
echo "TEST_2=COMMIT_AUTHORIZATION_DEFAULTS_FALSE"
echo "TEST_3=PUSH_AUTHORIZATION_DEFAULTS_FALSE"
echo "TEST_4=COMMIT_AUTHORIZATION_DOES_NOT_ENABLE_PUSH"
echo "TEST_5=VERSION_CONTROL_AUTHORIZATION_DOES_NOT_ENABLE_SHELL"
echo "TEST_6=ORDINARY_PLANNING_ENVELOPES_REMAIN_BACKWARD_COMPATIBLE"

echo
echo "=== NEXT DECISION ==="
echo "QUESTION=CAN_THE_FIRST_IMPLEMENTATION_UNIT_BE_PATCHED_WITHOUT_TOUCHING_EXISTING_PLANNING_BEHAVIOR"
echo "NEXT_ACTION=CLASSIFY_EXACT_PATCH_SET_AND_TEST_COMMANDS"
