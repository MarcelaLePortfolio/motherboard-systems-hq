#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PHASE 3 FAIL-CLOSED CONTRACT PRESERVATION ==="

current_result="scripts/classify-current-phase-3-repeated-unseeded-validation-result.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 472055c6 HEAD
test -f "$current_result"

echo
echo "=== VERIFY GOVERNING CURRENT RESULT ==="

grep -q 'PHASE_3_PRODUCTION_STABILITY_RESULT=' "$current_result"
grep -q 'UNSTABLE' "$current_result"
grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10' "$current_result"
grep -q 'PRESERVED_ON_ALL_10_OBSERVED_FAILURES' "$current_result"
grep -q 'UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE' "$current_result"

echo "CURRENT_PHASE_3_RESULT=CONFIRMED"

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

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo "PRODUCTION_BASELINE=CONFIRMED"

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=FAIL_CLOSED_CONTRACT_PRESERVATION

PHASE_3_PRODUCTION_STABILITY_RESULT=
  UNSTABLE

DETERMINISTIC_FAIL_CLOSED_ENFORCEMENT=
  PRESERVED

OBSERVED_PHASE_3_REJECTIONS=
  10_OF_10

PRIMARY_REJECTION_SURFACE=
  UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE

VALIDATOR_BEHAVIOR=
  CORRECT_ON_OBSERVED_SURFACE

RATIONALE=
  All ten current Phase 3 runs produced invalid model-authored project-context
  support provenance and were rejected by the deterministic invocation-aware
  validator.

  Those rejections demonstrate preservation of the fail-closed contract on
  the observed production-equivalent surface rather than validator malfunction.

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
  UNCHANGED_UNCONFIGURED_UNSEEDED

PRODUCTION_CHANGE=
  NONE

FAIL_CLOSED_CONTRACT_PRESERVATION=
  COMPLETE

NEXT_CORRIDOR=
  SINGLE_OLLAMA_INVOCATION_PRESERVATION

NEXT_ACTION=
  RUN_DR_BEFORE_CORRIDOR_4
MAP
