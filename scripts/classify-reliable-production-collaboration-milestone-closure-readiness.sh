#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY RELIABLE PRODUCTION COLLABORATION MILESTONE CLOSURE READINESS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 1f09ae5e HEAD
git merge-base --is-ancestor 623a2593 HEAD
git merge-base --is-ancestor fadc2e72 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-reliable-production-collaboration-milestone-closure-readiness\.sh$|^ M scripts/classify-reliable-production-collaboration-milestone-closure-readiness\.sh$' ||
  true
)"
test -z "$unexpected"

phase2="scripts/close-intervention-selection-corridor-and-phase-2.sh"
corridor2="scripts/close-production-behavioral-reliability-confirmation-and-enter-fail-closed-and-provenance-contract-confirmation.sh"
corridor3="scripts/close-fail-closed-and-provenance-contract-confirmation-and-enter-architectural-invariant-confirmation.sh"
corridor4="scripts/close-architectural-invariant-confirmation-and-enter-milestone-closure-readiness.sh"

for file in "$phase2" "$corridor2" "$corridor3" "$corridor4"; do
  test -f "$file"
done

grep -q 'PHASE_2_STATUS=' "$phase2"
grep -q '^CLOSED$' <(awk '/PHASE_2_STATUS=/{getline; print}' "$phase2")

grep -q 'CORRIDOR_2_STATUS=' "$corridor2"
grep -q '^CLOSED$' <(awk '/CORRIDOR_2_STATUS=/{getline; print}' "$corridor2")

grep -q 'CORRIDOR_3_STATUS=' "$corridor3"
grep -q '^CLOSED$' <(awk '/CORRIDOR_3_STATUS=/{getline; print}' "$corridor3")

grep -q 'CORRIDOR_4_STATUS=' "$corridor4"
grep -q '^CLOSED$' <(awk '/CORRIDOR_4_STATUS=/{getline; print}' "$corridor4")

grep -q 'ACTIVE_CORRIDOR=' "$corridor4"
grep -q '^MILESTONE_CLOSURE_READINESS$' \
  <(awk '/ACTIVE_CORRIDOR=/{getline; print}' "$corridor4")

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: unauthorized explicit production generation control detected."
  exit 2
fi

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

PHASE_1=
STARTING_BOUNDARY_AND_RELIABILITY_BASELINE

PHASE_1_STATUS=
CLOSED

PHASE_1_DR=
20260814_205409

PHASE_2=
GENERATION_LAYER_INTERVENTION_INVESTIGATION

PHASE_2_STATUS=
CLOSED

PHASE_2_RESULT=
SUCCESSFUL_BOUNDED_PRODUCTION_PROMPT_PRESENTATION_INTERVENTION_IMPLEMENTED_AND_VALIDATED

PHASE_3=
PRODUCTION_RELIABILITY_VALIDATION_AND_MILESTONE_CLOSURE

PHASE_3_CORRIDOR_1=
RELIABILITY_CONTRACT_RECONCILIATION

PHASE_3_CORRIDOR_1_STATUS=
CLOSED

PHASE_3_CORRIDOR_1_DR=
20260816_183033

PHASE_3_CORRIDOR_2=
PRODUCTION_BEHAVIORAL_RELIABILITY_CONFIRMATION

PHASE_3_CORRIDOR_2_STATUS=
CLOSED

PHASE_3_CORRIDOR_2_DR=
20260816_200309

PHASE_3_CORRIDOR_3=
FAIL_CLOSED_AND_PROVENANCE_CONTRACT_CONFIRMATION

PHASE_3_CORRIDOR_3_STATUS=
CLOSED

PHASE_3_CORRIDOR_3_DR=
20260816_201301

PHASE_3_CORRIDOR_4=
ARCHITECTURAL_INVARIANT_CONFIRMATION

PHASE_3_CORRIDOR_4_STATUS=
CLOSED

PHASE_3_CORRIDOR_4_DR=
20260816_210935

PHASE_3_CORRIDOR_5=
MILESTONE_CLOSURE_READINESS

RELIABILITY_TARGET=
SATISFIED_ON_TESTED_PRODUCTION_SURFACE

PRODUCTION_INTERVENTION=
EXPLICIT_PARENT_CHILD_PRESENTATION_SEPARATION_AS_PRODUCTION_DEFAULT

POST_PROMOTION_BEHAVIORAL_RESULT=
10_OF_10_SEMANTIC_PASS

UNSUPPORTED_PROVENANCE_FAILURES=
0_OF_10

FAIL_CLOSED_OR_RUNTIME_REJECTIONS=
0_OF_10

DETERMINISTIC_REGRESSION=
127_OF_127_PASS

FAIL_CLOSED_VALIDATION=
PRESERVED

SUPPORT_PROVENANCE_CONTRACT=
PRESERVED

ARCHITECTURAL_INVARIANTS=
PRESERVED

ONE_WORKFLOW_ONE_OLLAMA_INVOCATION=
PRESERVED

MODEL=
UNCHANGED

GENERATION_POLICY=
UNCHANGED

RETRY_OR_SECOND_MODEL_CALL=
NONE

ADDITIONAL_RELIABILITY_INTERVENTION_REQUIRED=
NO_CURRENT_EVIDENCE_SUPPORTED_REQUIREMENT

UNRESOLVED_MILESTONE_BLOCKER=
NONE_ESTABLISHED

NEW_PRODUCTION_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO_NEW_IMPLEMENTATION

MILESTONE_CLOSURE_READINESS=
READY_ON_CURRENT_REPOSITORY_EVIDENCE

CORRIDOR_5_STATUS=
READY_FOR_CLOSURE

NEXT_ACTION=
RUN_DR_BEFORE_FINAL_PHASE_3_AND_MILESTONE_CLOSURE
MAP
