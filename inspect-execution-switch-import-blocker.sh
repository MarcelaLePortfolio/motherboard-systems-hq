#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT EXECUTION SWITCH IMPORT BLOCKER ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "CONTRACT_IMPLEMENTATION_RETRY=PAUSED"
echo "FAILED_CONTRACT_HYPOTHESIS_COUNT=1"
echo "CURRENT_BLOCKER=ERR_MODULE_NOT_FOUND_FOR_EXECUTION_SWITCH_EVALUATOR"

EXPECTED_HEAD_PREFIX="df85b7658"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== LOCATE EXECUTION SWITCH EVALUATOR FILES ==="
find server -type f \( \
  -name '*execution-switch*' -o \
  -name '*switch-evaluator*' -o \
  -name 'matilda-execution-switch-evaluator.*' \
\) -print | sort

echo
echo "=== SEARCH IMPORTS ==="
git grep -n -I 'matilda-execution-switch-evaluator' -- server routes app src lib packages || true

echo
echo "=== INSPECT APPROVAL GATE IMPORT ==="
nl -ba server/execution/execution-approval-gate.mjs | sed -n '1,40p'

echo
echo "=== INSPECT CANDIDATE EVALUATOR FILES ==="
while IFS= read -r file; do
  echo
  echo "--- ${file} ---"
  nl -ba "${file}" | sed -n '1,220p'
done < <(
  find server -type f \( \
    -name '*execution-switch*' -o \
    -name '*switch-evaluator*' -o \
    -name 'matilda-execution-switch-evaluator.*' \
  \) | sort
)

echo
echo "=== CHECK WHETHER BLOCKER PREDATES CURRENT CONTRACT WORK ==="
git show 42b9d3fb0:server/execution/execution-approval-gate.mjs | sed -n '1,12p'

echo
echo "=== CHECK FILE EXISTENCE AT AUTHORIZATION CHECKPOINT ==="
for candidate in \
  server/execution/matilda-execution-switch-evaluator.js \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/matilda-execution-switch-evaluator.mjs
do
  if git cat-file -e "42b9d3fb0:${candidate}" 2>/dev/null; then
    echo "EXISTED_AT_42b9d3fb0=${candidate}"
  else
    echo "ABSENT_AT_42b9d3fb0=${candidate}"
  fi
done

echo
echo "=== CURRENT WORKTREE STATUS ==="
git status --short

echo
echo "=== BLOCKER CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=IS_APPROVAL_GATE_IMPORT_TARGET_WRONG_EXTENSION"
echo "QUESTION_2=IS_EVALUATOR_TYPESCRIPT_ONLY"
echo "QUESTION_3=IS_THIS_PRE_EXISTING_BEFORE_VERSION_CONTROL_WORK"
echo "QUESTION_4=DO_EXISTING_CALLERS_EXPECT_RUNTIME_COMPILATION_OR_DIRECT_NODE_ESM"
echo "QUESTION_5=CAN_BLOCKER_BE_FIXED_INDEPENDENTLY_WITHOUT_CHANGING_CONTRACT_SEMANTICS"

echo
echo "=== FAILURE CONTAINMENT ==="
echo "NO_FURTHER_CONTRACT_PATCH_UNTIL_BLOCKER_CLASSIFIED=YES"
echo "NO_SPECULATIVE_IMPORT_EDIT=YES"
echo "NO_GIT_RUNTIME_SIDE_EFFECTS=YES"
echo "THREE_FAILED_HYPOTHESIS_RULE=ACTIVE"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_IMPORT_BLOCKER_AND_DECIDE_FIX_OR_TEST_PATH"
