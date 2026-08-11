#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 SINGLE OLLAMA INVOCATION PRESERVATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY FAIL-CLOSED PRESERVATION CHECKPOINT ==="
expected_head="595571a2"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches fail-closed preservation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-single-ollama-invocation-preservation\.sh$|^ M scripts/classify-phase-3-single-ollama-invocation-preservation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "FAIL_CLOSED_PRESERVATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PHASE 3 STATE ==="

grep -nE \
  'FAIL_CLOSED_CONTRACT_PRESERVATION=|COMPLETE|NEXT_CORRIDOR=|SINGLE_OLLAMA_INVOCATION_PRESERVATION|NEXT_ACTION=|CLASSIFY_PHASE_3_SINGLE_OLLAMA_INVOCATION_PRESERVATION' \
  scripts/classify-phase-3-fail-closed-contract-preservation.sh

echo "GOVERNING_PHASE_3_STATE=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION OLLAMA CALL SURFACE ==="

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"

echo "PRODUCTION_OLLAMA_CALL_COUNT=$production_call_count"

if [[ "$production_call_count" -ne 1 ]]; then
  echo "STOP: production workflow does not contain exactly one ollamaChat invocation."
  exit 2
fi

grep -n -A18 -B4 \
  'await ollamaChat(message' \
  server/matilda-chat-workflow.ts

echo "PRODUCTION_SINGLE_OLLAMA_CALL=CONFIRMED"

echo
echo "=== VERIFY NO RETRY OR SECOND-CALL PATH ==="

if grep -nE \
  'retry|retries|second.*ollama|ollamaChat\(.*ollamaChat|Promise\.all\(.*ollamaChat' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains a possible retry or additional Ollama-call surface."
  exit 2
fi

echo "PRODUCTION_RETRY_OR_SECOND_CALL_SURFACE=ABSENT"

echo
echo "=== VERIFY GENERATION POLICY REMAINS UNCHANGED ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

echo "PRODUCTION_GENERATION_POLICY=UNCHANGED"

echo
echo "=== SINGLE INVOCATION PRESERVATION CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=SINGLE_OLLAMA_INVOCATION_PRESERVATION
UNIT=SINGLE_INVOCATION_PRESERVATION_CLASSIFICATION

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

RATIONALE=
  The production workflow continues to contain exactly one direct ollamaChat
  invocation for one user message.

  Phase 3 validation infrastructure does not alter that workflow invariant.

  Fail-closed semantic rejection remains terminal for the affected invocation
  and does not trigger a retry or second semantic generation attempt.

ONE_USER_MESSAGE_TO_ONE_OLLAMA_INVOCATION=
  PRESERVED

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

PRODUCTION_SEED=
  NOT_AUTHORIZED

PRODUCTION_TEMPERATURE=
  NOT_AUTHORIZED

PRODUCTION_TOP_P=
  NOT_AUTHORIZED

PRODUCTION_TOP_K=
  NOT_AUTHORIZED

MODEL_CHANGE=
  NOT_AUTHORIZED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

SINGLE_OLLAMA_INVOCATION_PRESERVATION=
  COMPLETE

NEXT_CORRIDOR=
  PRODUCTION_REGRESSION_VALIDATION

NEXT_ACTION=
  CLASSIFY_PHASE_3_PRODUCTION_REGRESSION_VALIDATION_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-single-ollama-invocation-preservation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
