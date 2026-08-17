#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 1 — CLASSIFICATION RULE CLOSURE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor fd52f8e1 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-phase-3-corridor-1-classification-rule\.sh$|^ M scripts/close-phase-3-corridor-1-classification-rule\.sh$' ||
  true
)"
test -z "$unexpected"

grep -q 'Set explanationStatus to optional by default.' scripts/utils/ollamaChat.ts
grep -q "Set explanationStatus to recommended only when skipping supporting reasoning is likely to materially affect the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -q 'Do not set explanationStatus to recommended merely because evidence exists, the work was substantial, or additional explanation is available.' scripts/utils/ollamaChat.ts

npx tsx --test scripts/utils/ollamaChat.explanation-status.test.ts
bash scripts/guard-ollama-response-contract.sh

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_1=CLASSIFICATION_RULE
CORRIDOR_1_STATUS=CLOSED
CANONICAL_RULE=OPTIONAL_DEFAULT_RECOMMENDED_ONLY_WHEN_SKIPPING_REASONING_IS_LIKELY_TO_MATERIALLY_AFFECT_THE_USERS_NEXT_ENGINEERING_DECISION
IMPLEMENTATION_STATUS=COMPLETE
PROMPT_CONTRACT_VALIDATION=PASS
FAIL_CLOSED_VALIDATION=PRESERVED
ONE_WORKFLOW_ONE_OLLAMA_INVOCATION=PRESERVED
SCHEMA_CHANGE=NONE
WORKFLOW_CHANGE=NONE
PERSISTENCE_CHANGE=NONE
MANDATORY_USER_FACING_CLASSIFIER_LINE=NO
CORRIDOR_1_RESULT=MATILDA_PRODUCTION_PROMPT_NOW_EXPLICITLY_OWNS_THE_OPTIONAL_VS_RECOMMENDED_REASONING_CLASSIFICATION_RULE
NEXT_CORRIDOR=BEHAVIOR_VALIDATION
NEXT_ACTION=RUN_DR_TO_CLOSE_CORRIDOR_1
MAP
