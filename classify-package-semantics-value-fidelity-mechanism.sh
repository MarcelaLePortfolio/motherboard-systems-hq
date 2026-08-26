#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PACKAGE SEMANTICS VALUE FIDELITY MECHANISM ==="
echo "EXPECTED_HEAD_PREFIX=a60c3f1a3"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != a60c3f1a3* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CURRENT WORKFLOW INPUT SURFACE ==="
rg -n -C 10 \
  'runMatildaConversationWorkflow|message:|message,|userMessage|ollamaChat\(message' \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  | head -320 || true

echo
echo "=== STRUCTURED PACKAGE SEMANTICS INPUT SIGNAL SEARCH ==="
rg -n -C 6 \
  'expectedOutcome|proposedWork|proposedArtifacts|inScope|outOfScope|constraints|unresolvedQuestions|packageSemantics' \
  server \
  routes \
  db \
  client/src \
  --glob '!**/*.test.ts' \
  | head -420 || true

echo
echo "=== USER MESSAGE TRANSPORT INTO OLLAMA ==="
rg -n -C 14 -F 'await ollamaChat(message' \
  server/matilda-chat-workflow.ts || true

echo
echo "=== OLLAMA CONTEXT INPUT TYPE ==="
sed -n '250,325p' scripts/utils/ollamaChat.ts

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=DOES_NORMAL_WORKFLOW_RECEIVE_EXPLICIT_PACKAGE_FIELDS_SEPARATELY_FROM_RAW_USER_MESSAGE"
echo "QUESTION_2=DOES_ANY_EXISTING_TYPED_USER_INTENT_OBJECT_CARRY_EXPECTED_OUTCOME_OR_OTHER_PACKAGE_SEMANTICS"
echo "QUESTION_3=IS_RAW_USER_MESSAGE_THE_ONLY_AUTHORITATIVE_CURRENT_TURN_SOURCE_FOR_PACKAGE_FIELD_MEANING"
echo "QUESTION_4=CAN_DETERMINISTIC_VALUE_FIDELITY_BE_ENFORCED_WITHOUT_PARSING_OR_HEURISTICALLY_EXTRACTING_FIELD_VALUES_FROM_NATURAL_LANGUAGE"
echo "QUESTION_5=WOULD_EXACT_VALUE_PRESERVATION_REQUIRE_A_NEW_EXPLICIT_STRUCTURED_USER_INPUT_CONTRACT"

echo
echo "=== SAFETY BOUNDARY ==="
echo "PROMPT_ONLY_RETRY=NOT_AUTHORIZED"
echo "HEURISTIC_EXTRACTION=NOT_AUTHORIZED"
echo "SECOND_OLLAMA_INVOCATION=NOT_AUTHORIZED"
echo "UI_FIELD_INFERENCE=NOT_AUTHORIZED"
echo "HISTORICAL_BACKFILL=NOT_AUTHORIZED"
echo "NEXT_ACTION=CLASSIFY_WHETHER_EXISTING_RUNTIME_ALREADY_HAS_A_TYPED_USER_SEMANTICS_SOURCE_OR_VALUE_FIDELITY_REQUIRES_A_NEW_INPUT_CONTRACT"

git diff --check

git add classify-package-semantics-value-fidelity-mechanism.sh
git commit -m "Classify package semantics value fidelity mechanism"
git push
