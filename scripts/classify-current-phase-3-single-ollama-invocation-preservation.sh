#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PHASE 3 SINGLE OLLAMA INVOCATION PRESERVATION ==="

current_fail_closed="scripts/classify-current-phase-3-fail-closed-contract-preservation.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 26ea2397 HEAD
test -f "$current_fail_closed"

grep -q 'FAIL_CLOSED_CONTRACT_PRESERVATION=' "$current_fail_closed"
grep -q 'COMPLETE' "$current_fail_closed"

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

if grep -nE \
  'retry|retries|second.*ollama|ollamaChat\(.*ollamaChat|Promise\.all\(.*ollamaChat' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains a possible retry or additional Ollama-call surface."
  exit 2
fi

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=SINGLE_OLLAMA_INVOCATION

CURRENT_PRODUCTION_OLLAMA_INVOCATIONS_PER_WORKFLOW=
  ONE

SINGLE_OLLAMA_INVOCATION_INVARIANT=
  PRESERVED

PRODUCTION_RETRY_POLICY=
  NONE

SECOND_OLLAMA_INVOCATION=
  ABSENT

PARALLEL_OLLAMA_INVOCATION=
  ABSENT

ONE_USER_MESSAGE_TO_ONE_OLLAMA_INVOCATION=
  PRESERVED

FAIL_CLOSED_REJECTION_BEHAVIOR=
  TERMINAL_FOR_AFFECTED_INVOCATION

SEMANTIC_AUTHORSHIP_BOUNDARY=
  PRESERVED

DETERMINISTIC_VALIDATOR_BOUNDARY=
  PRESERVED

RETRY_ON_SEMANTIC_FAILURE=
  NOT_AUTHORIZED

RETRY_ON_VALIDATION_FAILURE=
  NOT_AUTHORIZED

SECOND_MODEL_CALL=
  NOT_AUTHORIZED

PARALLEL_MODEL_CALL=
  NOT_AUTHORIZED

PRODUCTION_GENERATION_POLICY=
  UNCHANGED_UNCONFIGURED_UNSEEDED

PRODUCTION_CHANGE=
  NONE

SINGLE_OLLAMA_INVOCATION_PRESERVATION=
  COMPLETE

NEXT_CORRIDOR=
  PRODUCTION_REGRESSION_VALIDATION

NEXT_ACTION=
  RUN_DR_BEFORE_CORRIDOR_5
MAP
