#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — CROSS-CUTTING SELECTED CONTEXT CONTRACT CLASSIFICATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 87096a62 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-corridor-2-cross-cutting-selected-context-contract\.sh$|^ M scripts/classify-phase-3-corridor-2-cross-cutting-selected-context-contract\.sh$' ||
  true
)"
test -z "$unexpected"

grep -Fq "Set selectedContextSegments to exactly the supplied project-context child segments whose content materially affects the immediate reply." scripts/utils/ollamaChat.ts
grep -Fq "Use only the exact relativePath, sourceStartLine, and sourceEndLine supplied for each selected child." scripts/utils/ollamaChat.ts
grep -Fq "Return [] when no supplied project-context child materially affects the immediate reply." scripts/utils/ollamaChat.ts
grep -Fq "Conversation history remains independent and does not require selectedContextSegments membership." scripts/utils/ollamaChat.ts

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_2=BEHAVIOR_VALIDATION
STATUS=BLOCKED_BY_CROSS_CUTTING_SELECTED_CONTEXT_GENERATION_BEHAVIOR
THREE_FAILED_BEHAVIOR_VALIDATION_ATTEMPTS=REACHED
NEW_BEHAVIOR_VALIDATION_ATTEMPT_AUTHORIZED=NO
SELECTED_CONTEXT_SEMANTIC_DOMAIN=SUPPLIED_PROJECT_CONTEXT_CHILD_SEGMENTS_ONLY
EMPTY_PROJECT_CONTEXT_CANDIDATE_UNIVERSE_REQUIRES=EMPTY_SELECTED_CONTEXT_SEGMENTS
PROMPT_RULE_EXPLICIT=YES
ATTEMPT_3_PROJECT_CONTEXT_CANDIDATES=NONE
ATTEMPT_3_MODEL_BEHAVIOR=AUTHORED_NONEMPTY_SELECTED_CONTEXT_SEGMENT
ATTEMPT_3_CONTRACT_RELATION=MODEL_OUTPUT_CONTRADICTED_EXPLICIT_SELECTED_CONTEXT_PROMPT_CONTRACT
FAIL_CLOSED_MEMBERSHIP_VALIDATION=CORRECT_BY_CURRENT_CONTRACT
VALIDATOR_MALFUNCTION_ESTABLISHED=NO
REASONING_STATUS_CLASSIFICATION_FAILURE_ESTABLISHED=NO
CROSS_CUTTING_SELECTED_CONTEXT_GENERATION_BLOCK=ESTABLISHED_FOR_CURRENT_BEHAVIOR_VALIDATION_SURFACE
PRODUCTION_CHANGE=NONE
DR_NOW=NO
NEXT_ACTION=CLASSIFY_WHETHER_CORRIDOR_2_CAN_BE_VALIDATED_WITH_A_NON_MODEL_CONTRACT_TEST_OR_MUST_BE_DEFERRED_AS_BLOCKED_BY_CROSS_CUTTING_GENERATION_INSTABILITY
MAP
