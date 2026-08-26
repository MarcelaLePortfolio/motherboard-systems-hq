#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT OPTION B VARIABLE DEFINITION SCOPE ==="
echo "EXPECTED_HEAD_PREFIX=415b595f5"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_ATTEMPT_1=FAILED"
echo "IMPLEMENTATION_ATTEMPT_2_STARTED=NO"
echo "PRODUCTION_CHANGE_COMMITTED=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 415b595f5* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== EXACT DEFINITION AND USE SITES ==="
rg -n -C 12 \
  'const validatedUserPackageSemantics|validatedUserPackageSemantics' \
  scripts/utils/ollamaChat.ts

echo
echo "=== FUNCTION BOUNDARIES AROUND EVERY SITE ==="
rg -n \
  '^export (async )?function |^async function |^function ' \
  scripts/utils/ollamaChat.ts \
  | sed -n '1,220p'

echo
echo "=== OLLAMA FUNCTION ENTRY THROUGH PROMPT SETUP ==="
sed -n '1070,1175p' scripts/utils/ollamaChat.ts

echo
echo "=== EARLIER CONTEXT-HISTORY REGION ==="
rg -n -C 25 -F 'const history = context.history ?? []' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== PACKAGE SEMANTICS PROMPT REGION ==="
rg -n -C 25 -F 'Explicit user-supplied Package Semantics' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== CLASSIFICATION TARGET ==="
echo "QUESTION_1=WHICH_FUNCTION_CURRENTLY_DEFINES_validatedUserPackageSemantics"
echo "QUESTION_2=IS_THAT_DEFINITION_INSIDE_ollamaChat"
echo "QUESTION_3=IS_PROMPT_CONSTRUCTION_AND_POST_PARSE_FIDELITY_CHECK_IN_THE_SAME_SCOPE"
echo "QUESTION_4=CAN_ATTEMPT_2_MOVE_ONE_EXISTING_DEFINITION_WITHOUT_CHANGING_THE_AUTHORIZED_CONTRACT"
echo "SOURCE_EDIT=NONE"
echo "NEXT_ACTION=ATTEMPT_2_ONLY_IF_ONE_EXACT_SCOPE_REPAIR_IS_UNAMBIGUOUS"

git diff --check

git add inspect-option-b-variable-definition-scope.sh
git commit -m "Inspect Option B variable definition scope"
git push
