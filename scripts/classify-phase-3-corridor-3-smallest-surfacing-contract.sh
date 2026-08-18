#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — SMALLEST SURFACING CONTRACT CLASSIFICATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor c8760f6a HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-corridor-3-smallest-surfacing-contract\.sh$|^ M scripts/classify-phase-3-corridor-3-smallest-surfacing-contract\.sh$|^\?\? scripts/investigate-phase-3-corridor-3-surfacing-surfaces\.sh$|^ M scripts/investigate-phase-3-corridor-3-surfacing-surfaces\.sh$' ||
  true
)"
test -z "$unexpected"

grep -Fq 'explanationStatus: MatildaExplanationStatus;' scripts/utils/ollamaChat.ts
grep -Fq 'reply: result.reply,' scripts/utils/ollamaChat.ts
grep -Fq 'explanationStatus: result.explanationStatus,' scripts/utils/ollamaChat.ts
grep -Fq 'For explanationStatus:' scripts/utils/ollamaChat.ts
grep -Fq 'For reply:' scripts/utils/ollamaChat.ts
grep -Fq 'Lead with a concise natural-language summary' scripts/utils/ollamaChat.ts

external_status_usage="$(
  grep -RIl 'explanationStatus' server routes app components \
    --include='*.ts' --include='*.tsx' 2>/dev/null || true
)"

cat <<MAP
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_3=SURFACING_CONTRACT
STATUS=ARCHITECTURALLY_CLASSIFIED

EXPLANATION_STATUS_AUTHORED_IN_EXISTING_OLLAMA_INVOCATION=YES
USER_VISIBLE_REPLY_AUTHORED_IN_SAME_EXISTING_OLLAMA_INVOCATION=YES
EXPLANATION_STATUS_RETURNED_FROM_ADAPTER=YES

EXTERNAL_WORKFLOW_OR_UI_EXPLANATION_STATUS_USAGE=$(
  if [[ -z "$external_status_usage" ]]; then
    printf 'NONE_FOUND'
  else
    printf 'FOUND'
  fi
)

EXTERNAL_USAGE_FILES=$(
  if [[ -z "$external_status_usage" ]]; then
    printf 'NONE'
  else
    printf '%s' "$external_status_usage" | tr '\n' ','
  fi
)

CURRENT_REPLY_COMPOSITION_ALREADY_MODEL_AUTHORED=YES

SMALLEST_SURFACING_CONTRACT=
COUPLE_EXISTING_EXPLANATION_STATUS_SELECTION_TO_EXISTING_REPLY_COMPOSITION_IN_THE_SAME_OLLAMA_PROMPT

OPTIONAL_SURFACING=
KEEP_REPLY_CONCISE_AND_INCLUDE_ONLY_REASONING_NEEDED_FOR_THE_IMMEDIATE_INTERACTION

RECOMMENDED_SURFACING=
KEEP_THE_CONCISE_ANSWER_FIRST_THEN_INCLUDE_ENOUGH_SUPPORTING_REASONING_TO_PRESERVE_THE_MATERIAL_BOUNDARY_UNCERTAINTY_TRADEOFF_OR_EVIDENCE_INTERPRETATION_THAT_COULD_CHANGE_THE_USERS_NEXT_DECISION

MANDATORY_VISIBLE_STATUS_LABEL=NO
UI_CHANGE_REQUIRED=NO
WORKFLOW_CONSUMPTION_OF_STATUS_REQUIRED=NO
NEW_RUNTIME_SEAM_REQUIRED=NO
NEW_STRUCTURED_ARTIFACT_REQUIRED=NO
MODEL_INVOCATION_COUNT_CHANGE=NO

BOUNDED_PRODUCTION_PROMPT_CHANGE_REQUIRED=
YES_TO_LINK_STATUS_SELECTION_AND_REPLY_DETAIL_SEMANTICS

CORRIDOR_2_RELIABILITY_LIMIT=
PRESERVE_EXPLICITLY

DO_NOT_CLAIM=
OPTIONAL_OR_RECOMMENDED_MODEL_BEHAVIOR_IS_PRODUCTION_RELIABLE

IMPLEMENTATION_REQUIRED=
YES_BOUNDED_TO_EXISTING_REPLY_COMPOSITION_PROMPT_CONTRACT

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

DR_NOW=
NO

NEXT_ACTION=
CLASSIFY_BOUNDED_CORRIDOR_3_IMPLEMENTATION_READINESS
MAP
