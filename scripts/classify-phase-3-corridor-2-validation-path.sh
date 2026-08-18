#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — VALIDATION PATH CLASSIFICATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 8b2e3743 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-corridor-2-validation-path\.sh$|^ M scripts/classify-phase-3-corridor-2-validation-path\.sh$' ||
  true
)"
test -z "$unexpected"

grep -Fq 'enum: ["optional", "recommended"]' scripts/utils/ollamaChat.ts
grep -Fq 'Set explanationStatus to optional by default.' scripts/utils/ollamaChat.ts
grep -Fq "Set explanationStatus to recommended only when skipping supporting reasoning is likely to materially affect the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -Fq 'Do not set explanationStatus to recommended merely because evidence exists, the work was substantial, or additional explanation is available.' scripts/utils/ollamaChat.ts

grep -Fq 'Set selectedContextSegments to exactly the supplied project-context child segments whose content materially affects the immediate reply.' scripts/utils/ollamaChat.ts
grep -Fq 'Return [] when no supplied project-context child materially affects the immediate reply.' scripts/utils/ollamaChat.ts

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_2=BEHAVIOR_VALIDATION
STATUS=VALIDATION_PATH_CLASSIFIED

MODEL_BEHAVIOR_VALIDATION_ATTEMPTS=3
FURTHER_MODEL_ATTEMPTS_AUTHORIZED=NO

REASONING_STATUS_SCHEMA_CONTRACT=ESTABLISHED
OPTIONAL_DEFAULT_PROMPT_CONTRACT=ESTABLISHED
RECOMMENDED_MATERIAL_DECISION_IMPACT_PROMPT_CONTRACT=ESTABLISHED
FALSE_POSITIVE_REJECTION_PROMPT_CONTRACT=ESTABLISHED

NON_MODEL_CONTRACT_TEST_CAN_ESTABLISH=
SCHEMA_AND_PROMPT_CLASSIFICATION_CONTRACT_ONLY

NON_MODEL_CONTRACT_TEST_CANNOT_ESTABLISH=
ACTUAL_MODEL_BEHAVIORAL_RELIABILITY

CURRENT_MODEL_BEHAVIORAL_RELIABILITY_STATUS=
NOT_ESTABLISHED_DUE_TO_CROSS_CUTTING_SELECTED_CONTEXT_GENERATION_BLOCK

CROSS_CUTTING_BLOCK=
MODEL_CAN_AUTHOR_INVALID_SELECTED_CONTEXT_BEFORE_REASONING_STATUS_RESULT_BECOMES_OBSERVABLE

FAIL_CLOSED_VALIDATION=
PRESERVED_AND_CORRECT_BY_CURRENT_CONTRACT

CORRIDOR_2_CLOSURE_BY_NON_MODEL_TEST_ALONE=
NOT_JUSTIFIED

CORRIDOR_2_DISPOSITION=
DEFER_BEHAVIORAL_RELIABILITY_VALIDATION_UNTIL_CROSS_CUTTING_GENERATION_INSTABILITY_IS_RESOLVED_OR_A_SEPARATELY_AUTHORIZED_VALIDATION_SURFACE_CAN_OBSERVE_REASONING_STATUS_WITHOUT_WEAKENING_CONTRACTS

REASONING_STATUS_DEFECT_ESTABLISHED=
NO

PRODUCTION_CHANGE=
NONE

DR_NOW=
NO

NEXT_ACTION=
CLASSIFY_CORRIDOR_2_DEFERRED_DISPOSITION_AND_WHETHER_PHASE_3_CAN_CONTINUE_TO_SURFACING_CONTRACT_WITH_THIS_LIMIT_EXPLICITLY_PRESERVED
MAP
