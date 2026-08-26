#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT OPTION B FIDELITY RUNTIME CALL SITES ==="
echo "EXPECTED_HEAD_PREFIX=d182dc932"
echo "CLASSIFICATION_COMMIT=d182dc932991b0c9c5e4bc419a8576ae2fe1cfef"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "SECOND_LIVE_INVOCATION_AUTHORIZED=NO"
echo "SOURCE_IMPLEMENTATION_CHANGE=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != d182dc932* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== EXACT SYMBOL REFERENCES ==="
rg -n -C 12 -F 'enforceMatildaUserPackageSemanticsFidelity' \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  server/matilda-chat-workflow.ts || true

echo
echo "=== REPOSITORY-WIDE SYMBOL REFERENCES ==="
rg -n -F 'enforceMatildaUserPackageSemanticsFidelity' . \
  --glob '!node_modules/**' \
  --glob '!dist/**' \
  --glob '!build/**' || true

echo
echo "=== POST-PARSE RUNTIME REGION ==="
PARSE_LINE="$(rg -n 'parseStructuredResponse\(rawResponse\)' scripts/utils/ollamaChat.ts | head -1 | cut -d: -f1)"
if [[ -z "${PARSE_LINE}" ]]; then
  echo "PARSE_CALL_NOT_FOUND"
  exit 1
fi
START=$((PARSE_LINE > 10 ? PARSE_LINE - 10 : 1))
END=$((PARSE_LINE + 75))
sed -n "${START},${END}p" scripts/utils/ollamaChat.ts

echo
echo "=== FUNCTION DEFINITION REGION ==="
DEFINITION_LINE="$(rg -n '^export function enforceMatildaUserPackageSemanticsFidelity' scripts/utils/ollamaChat.ts | head -1 | cut -d: -f1)"
if [[ -z "${DEFINITION_LINE}" ]]; then
  echo "FIDELITY_FUNCTION_DEFINITION_NOT_FOUND"
  exit 1
fi
START=$((DEFINITION_LINE > 10 ? DEFINITION_LINE - 10 : 1))
END=$((DEFINITION_LINE + 65))
sed -n "${START},${END}p" scripts/utils/ollamaChat.ts

echo
echo "=== CLASSIFICATION TARGET ==="
REFERENCE_COUNT="$(rg -n -F 'enforceMatildaUserPackageSemanticsFidelity' scripts/utils/ollamaChat.ts | wc -l | tr -d ' ')"
echo "OLLAMA_CHAT_SYMBOL_REFERENCE_COUNT=${REFERENCE_COUNT}"
echo "QUESTION_1=IS_THERE_ANY_RUNTIME_CALL_OUTSIDE_THE_FUNCTION_DEFINITION"
echo "QUESTION_2=IS_THERE_A_CALL_BETWEEN_parseStructuredResponse_AND_SELECTED_CONTEXT_REJECTION"
echo "QUESTION_3=ARE_ALL_NON_DEFINITION_CALLS_TEST_ONLY"
echo "IF_NO_RUNTIME_CALL=IMPLEMENTATION_INTEGRATION_DEFECT_CONFIRMED"
echo "IF_RUNTIME_CALL_EXISTS=CLASSIFY_EXACT_ORDER_BEFORE_ANY_CHANGE"
echo "NEXT_ACTION=CLASSIFY_FROM_OUTPUT_ONLY"
echo "SOURCE_EDIT=NONE"

git diff --check

git add inspect-option-b-fidelity-runtime-call-sites.sh
git commit -m "Inspect Option B fidelity runtime call sites"
git push
