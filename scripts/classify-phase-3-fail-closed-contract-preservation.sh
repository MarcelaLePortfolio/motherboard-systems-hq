#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 FAIL-CLOSED CONTRACT PRESERVATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY PHASE 3 RESULT CHECKPOINT ==="
expected_head="0a6549f5"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 unseeded-result checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-fail-closed-contract-preservation\.sh$|^ M scripts/classify-phase-3-fail-closed-contract-preservation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_3_RESULT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING RESULT ==="

grep -nE \
  'PHASE_3_PRODUCTION_STABILITY_RESULT=|UNSTABLE|FAIL_CLOSED_ENFORCEMENT_RESULT=|PRESERVED|PRIMARY_DETERMINISTIC_REJECTION_SURFACE=|UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE|NEXT_CORRIDOR=|FAIL_CLOSED_CONTRACT_PRESERVATION' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

echo "GOVERNING_PHASE_3_RESULT=CONFIRMED"

echo
echo "=== VERIFY FAIL-CLOSED VALIDATOR SURFACES ==="

grep -nF \
  'Ollama returned a selected context segment that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Ollama returned a conversation support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Ollama returned a project-context support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

echo "FAIL_CLOSED_VALIDATOR_SURFACES=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION BASELINE ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"

if [[ "$production_call_count" -ne 1 ]]; then
  echo "STOP: production workflow no longer has exactly one ollamaChat invocation."
  exit 2
fi

echo "PRODUCTION_BASELINE=CONFIRMED"

echo
echo "=== FAIL-CLOSED PRESERVATION CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=FAIL_CLOSED_CONTRACT_PRESERVATION
UNIT=FAIL_CLOSED_PRESERVATION_CLASSIFICATION

PHASE_3_PRODUCTION_STABILITY_RESULT=
  UNSTABLE

DETERMINISTIC_FAIL_CLOSED_ENFORCEMENT=
  PRESERVED

OBSERVED_PHASE_3_REJECTIONS=
  8_OF_10

PRIMARY_REJECTION_SURFACE=
  UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE

VALIDATOR_BEHAVIOR=
  CORRECT

RATIONALE=
  The Phase 3 sample established unstable model-authored generation behavior.

  Eight runs produced invalid project-context support provenance and were
  rejected by the deterministic invocation-aware validator.

  Those rejections demonstrate preservation of the fail-closed contract rather
  than validator malfunction.

  The remaining two runs failed the fixture semantic acceptance surface after
  successful adapter return and do not contradict preservation of the
  deterministic rejection boundary.

SELECTED_CONTEXT_VALIDATOR=
  PRESERVE

CONVERSATION_SUPPORT_VALIDATOR=
  PRESERVE

PROJECT_CONTEXT_SUPPORT_VALIDATOR=
  PRESERVE

VALIDATOR_RELAXATION=
  NOT_AUTHORIZED

SILENT_REPAIR_OF_MODEL_AUTHORED_IDENTITIES=
  NOT_AUTHORIZED

RETRY_ON_VALIDATION_FAILURE=
  NOT_AUTHORIZED

SECOND_OLLAMA_INVOCATION=
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

PROMPT_CHANGE=
  NOT_AUTHORIZED_BY_THIS_CORRIDOR

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

FAIL_CLOSED_CONTRACT_PRESERVATION=
  COMPLETE

NEXT_CORRIDOR=
  SINGLE_OLLAMA_INVOCATION_PRESERVATION

NEXT_ACTION=
  CLASSIFY_PHASE_3_SINGLE_OLLAMA_INVOCATION_PRESERVATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-fail-closed-contract-preservation\.sh$' ||
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
