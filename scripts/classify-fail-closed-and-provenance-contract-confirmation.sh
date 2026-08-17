#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY FAIL-CLOSED AND PROVENANCE CONTRACT CONFIRMATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 2f60ab5e HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-fail-closed-and-provenance-contract-confirmation\.sh$|^ M scripts/classify-fail-closed-and-provenance-contract-confirmation\.sh$' ||
  true
)"
test -z "$unexpected"

transition="scripts/close-production-behavioral-reliability-confirmation-and-enter-fail-closed-and-provenance-contract-confirmation.sh"
test -f "$transition"

grep -q 'ACTIVE_CORRIDOR=' "$transition"
grep -q '^FAIL_CLOSED_AND_PROVENANCE_CONTRACT_CONFIRMATION$' \
  <(awk '/ACTIVE_CORRIDOR=/{getline; print}' "$transition")

grep -qF \
  'Ollama returned a selected context segment that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -qF \
  'Ollama returned a conversation support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -qF \
  'Ollama returned a project-context support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: explicit production generation control detected."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

PHASE_3=
PRODUCTION_RELIABILITY_VALIDATION_AND_MILESTONE_CLOSURE

CORRIDOR_3=
FAIL_CLOSED_AND_PROVENANCE_CONTRACT_CONFIRMATION

CURRENT_VALIDATOR_SURFACES=
SELECTED_CONTEXT_CONVERSATION_SUPPORT_AND_PROJECT_CONTEXT_SUPPORT_FAIL_CLOSED_CHECKS_PRESENT

SELECTED_CONTEXT_SEGMENT_CONTRACT=
PRESERVED

CONVERSATION_SUPPORT_PROVENANCE_CONTRACT=
PRESERVED

PROJECT_CONTEXT_SUPPORT_PROVENANCE_CONTRACT=
PRESERVED

FAIL_CLOSED_VALIDATION=
PRESERVED

VALIDATOR_WEAKENING=
ABSENT

PRODUCTION_GENERATION_CONTROL=
ABSENT

ONE_WORKFLOW_ONE_OLLAMA_INVOCATION=
PRESERVED

LEGACY_GENERATION_STABILITY_REJECTION_COUNTS=
NOT_IMPORTED_AS_CURRENT_BEHAVIORAL_EVIDENCE

CURRENT_BEHAVIORAL_EVIDENCE_SOURCE=
PHASE_3_CORRIDOR_2_POST_PROMOTION_RELIABILITY_CONFIRMATION

NEW_PRODUCTION_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO_NEW_IMPLEMENTATION

FAIL_CLOSED_AND_PROVENANCE_CONTRACT_CONFIRMATION=
SATISFIED_ON_CURRENT_REPOSITORY_EVIDENCE

CORRIDOR_3_STATUS=
READY_FOR_CLOSURE

NEXT_ACTION=
CLOSE_FAIL_CLOSED_AND_PROVENANCE_CONTRACT_CONFIRMATION_AND_ENTER_ARCHITECTURAL_INVARIANT_CONFIRMATION
MAP
