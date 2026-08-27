#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT CADE LOCAL COMMIT EXTENSION POINTS ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "LOCAL_COMMIT_IMPLEMENTATION_AUTHORIZED=NO"
echo "REMOTE_PUSH_INCLUDED=NO"

EXPECTED_HEAD_PREFIX="fcb1f57d8"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CURRENT WORKTREE ==="
git status --short

echo
echo "=== CADE EXECUTOR ==="
nl -ba server/cade/cade-executor.ts | sed -n '1,260p'

echo
echo "=== CADE EFFECTS ==="
nl -ba server/cade/cade-effects.ts | sed -n '1,320p'

echo
echo "=== CADE EVENT WRAPPER ==="
nl -ba server/cade/cade-event-wrapper.ts | sed -n '1,320p'

echo
echo "=== EXECUTION EVENT BUS ==="
nl -ba server/events/execution-event-bus.ts | sed -n '1,360p'

echo
echo "=== EXECUTION EVENT STORE ==="
nl -ba server/events/execution-event-store.ts | sed -n '1,360p'

echo
echo "=== CADE EXECUTOR CALLERS ==="
git grep -n -I -E \
  'executeCadeAction|CadeAction|cade-executor' \
  -- server routes app src lib packages \
  | sed -n '1,520p' || true

echo
echo "=== EXECUTION EVENT TYPE / PERSISTENCE CALLERS ==="
git grep -n -I -E \
  'recordExecutionEvent|emitPersistentEvent|ExecutionEvent|affectedFiles' \
  -- server routes app src lib packages \
  | sed -n '1,620p' || true

echo
echo "=== EXISTING SAFE GIT PROCESS PATTERNS ==="
for f in \
  server/project-registry.mjs \
  server/matilda-project-context-retrieval.ts
do
  echo
  echo "--- ${f} ---"
  grep -n -C 8 -E \
    'execFileSync|git.*rev-parse|git.*status|git.*init|git.*diff' \
    "${f}" || true
done

echo
echo "=== CURRENT VERSION CONTROL CONTRACT SURFACES ==="
grep -n -C 6 -E \
  'expected_head|version_control_authorization|commit_authorized|push_authorized' \
  server/contracts/execution-envelope.v1.mjs \
  server/execution/build-approval-artifact.mjs \
  server/execution/execution-approval-gate.mjs \
  server/guards/validate-execution-envelope.mjs

echo
echo "=== APPROVAL GATE CURRENT EFFECTIVE OUTPUT ==="
nl -ba server/execution/execution-approval-gate.mjs | sed -n '1,180p'

echo
echo "=== SEARCH FOR AUTHORIZED FILE-SET TRANSPORT INTO CADE ==="
git grep -n -I -E \
  'allowed_paths|patch_spec|affectedFiles|payload.*filename|filename.*payload|executionId|approval_id|envelope_id' \
  -- server/cade server/execution server/routes routes \
  | sed -n '1,720p' || true

echo
echo "=== LOCAL COMMIT DESIGN QUESTIONS ==="
echo "QUESTION_1=SHOULD_GIT_PROCESS_EXECUTION_LIVE_IN_NEW_CADE_EFFECT_MODULE"
echo "QUESTION_2=SHOULD_CADE_EXECUTOR_ADD_A_DISTINCT_COMMIT_ACTION"
echo "QUESTION_3=HOW_DOES_EXECUTOR_RECEIVE_APPROVAL_ARTIFACT_AND_EXECUTION_ENVELOPE"
echo "QUESTION_4=WHERE_IS_EXPECTED_HEAD_VERIFIED_CLOSEST_TO_SIDE_EFFECT"
echo "QUESTION_5=WHERE_IS_ALLOWED_PATH_SET_VERIFIED_CLOSEST_TO_STAGING"
echo "QUESTION_6=CAN_EXISTING_EXECUTION_EVENT_SCHEMA_RECORD_PRE_HEAD_POST_HEAD_APPROVAL_ID_AND_COMMITTED_FILES"
echo "QUESTION_7=DOES_EVENT_SCHEMA_REQUIRE_A_NARROW_EXTENSION"
echo "QUESTION_8=CAN_LOCAL_COMMIT_BE_IMPLEMENTED_WITHOUT_GENERIC_MUTATION_OR_SHELL_AUTHORITY"
echo "QUESTION_9=WHAT_CALLER_MUST_PROVE_COMMIT_AUTHORIZED_TRUE_BEFORE_CADE_ACTION_REACHES_EFFECT"

echo
echo "=== REQUIRED FIRST EFFECT UNIT BOUNDARY ==="
echo "ACTION_NAME_CANDIDATE=commit_changes"
echo "REMOTE_PUSH=NO"
echo "GENERIC_SHELL=NO"
echo "PROCESS_EXECUTION=execFileSync_OR_execFile_ARGUMENT_ARRAY"
echo "GIT_ADD_DOT=NO"
echo "FORCE_PUSH=NO"
echo "EXPECTED_HEAD_REQUIRED=YES"
echo "BRANCH_REQUIRED=YES"
echo "REPOSITORY_REQUIRED=YES"
echo "APPROVED_PATHS_REQUIRED=YES"
echo "COMMIT_MESSAGE_REQUIRED=YES"
echo "COMMIT_AUTHORIZED_TRUE_REQUIRED=YES"
echo "PUSH_AUTHORIZED_NOT_REQUIRED=YES"
echo "POST_COMMIT_PARENT_MUST_EQUAL_EXPECTED_HEAD=YES"
echo "ACTUAL_COMMITTED_PATHS_MUST_EQUAL_STAGED_AUTHORIZED_PATHS=YES"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "NO_CADE_EXECUTOR_EDIT=YES"
echo "NO_CADE_EFFECT_EDIT=YES"
echo "NO_EVENT_SCHEMA_EDIT=YES"
echo "NO_GIT_COMMAND_EXECUTED=YES"
echo "NO_REMOTE_WRITE=YES"
echo "NO_APPROVAL_POLICY_CHANGE=YES"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_EXACT_LOCAL_COMMIT_PATCH_SET_AND_PROVENANCE_CONTRACT"
