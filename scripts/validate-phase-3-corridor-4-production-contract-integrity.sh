#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 4 — PRODUCTION CONTRACT INTEGRITY VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 24fa7152 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-phase-3-corridor-4-production-contract-integrity\.sh$|^ M scripts/validate-phase-3-corridor-4-production-contract-integrity\.sh$' ||
  true
)"
test -z "$unexpected"

npx tsx --test scripts/utils/ollamaChat.explanation-status.test.ts
npx tsx --test scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts
bash scripts/guard-ollama-response-contract.sh

grep -Fq 'Set explanationStatus to optional by default.' scripts/utils/ollamaChat.ts
grep -Fq "Set explanationStatus to recommended only when skipping supporting reasoning is likely to materially affect the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -Fq 'Do not set explanationStatus to recommended merely because evidence exists, the work was substantial, or additional explanation is available.' scripts/utils/ollamaChat.ts
grep -Fq 'Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label.' scripts/utils/ollamaChat.ts
grep -Fq 'When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction.' scripts/utils/ollamaChat.ts
grep -Fq "When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -Fq 'Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present.' scripts/utils/ollamaChat.ts

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 1
fi

git diff --check

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_4=PRODUCTION_VALIDATION_AND_CLOSURE
STATUS=PRODUCTION_CONTRACT_INTEGRITY_VALIDATED
CLASSIFICATION_CONTRACT=PASS
SURFACING_CONTRACT=PASS
RESPONSE_CONTRACT_GUARD=PASS
INVESTIGATION_LIFECYCLE_GUARD=PASS
SINGLE_OLLAMA_INVOCATION=PRESERVED
PRODUCTION_VALIDATION_SEED=ABSENT
FAIL_CLOSED_VALIDATION=PRESERVED
VISIBLE_REASONING_STATUS_LABEL=NO
MODEL_BEHAVIORAL_RELIABILITY=NOT_ESTABLISHED
CORRIDOR_2_DEFERRED_LIMIT=PRESERVED
FOURTH_MODEL_VALIDATION_ATTEMPT=NOT_RUN
PRODUCTION_CHANGE=NONE
DR_NOW=NO
NEXT_ACTION=CLASSIFY_PHASE_3_BOUNDED_CLOSURE_READINESS_WITH_BEHAVIORAL_RELIABILITY_EXPLICITLY_DEFERRED
MAP
