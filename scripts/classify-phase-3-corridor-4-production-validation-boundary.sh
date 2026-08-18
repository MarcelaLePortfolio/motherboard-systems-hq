#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 4 — PRODUCTION VALIDATION BOUNDARY CLASSIFICATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor bf086564 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-corridor-4-production-validation-boundary\.sh$|^ M scripts/classify-phase-3-corridor-4-production-validation-boundary\.sh$' ||
  true
)"
test -z "$unexpected"

grep -Fq 'Set explanationStatus to optional by default.' scripts/utils/ollamaChat.ts
grep -Fq "Set explanationStatus to recommended only when skipping supporting reasoning is likely to materially affect the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -Fq 'Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label.' scripts/utils/ollamaChat.ts
grep -Fq 'Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present.' scripts/utils/ollamaChat.ts

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow now supplies validationGenerationSeed."
  exit 1
fi

npx tsx --test scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts
bash scripts/guard-ollama-response-contract.sh
git diff --check

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_4=PRODUCTION_VALIDATION_AND_CLOSURE
STATUS=PRODUCTION_VALIDATION_BOUNDARY_CLASSIFIED
CONTRACT_LEVEL_VALIDATION=PASS
MODEL_BEHAVIORAL_RELIABILITY=NOT_ESTABLISHED
FOURTH_REPLAY_OF_SAME_SELECTED_CONTEXT_VALIDATION_PATH=FORBIDDEN
CORRIDOR_2_DEFERRED_LIMIT=MUST_REMAIN_UNRESOLVED
FAIL_CLOSED_VALIDATION=MUST_REMAIN_UNCHANGED
PHASE_3_FULL_BEHAVIORAL_RELIABILITY_CLOSURE_AVAILABLE=NO
PHASE_3_BOUNDED_CLOSURE_AVAILABLE=YES_WITH_EXPLICIT_DEFERRED_BEHAVIORAL_RELIABILITY_LIMIT
PRODUCTION_CHANGE_REQUIRED=NO
IMPLEMENTATION_AUTHORIZED=NO
DR_NOW=NO
NEXT_ACTION=VALIDATE_CURRENT_PRODUCTION_CONTRACT_INTEGRITY_THEN_CLASSIFY_PHASE_3_BOUNDED_CLOSURE_WITH_CORRIDOR_2_RELIABILITY_LIMIT_EXPLICITLY_DEFERRED
MAP
