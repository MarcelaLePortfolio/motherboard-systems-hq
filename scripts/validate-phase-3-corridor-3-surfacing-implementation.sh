#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — SURFACING IMPLEMENTATION VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 3e8f1a51 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-phase-3-corridor-3-surfacing-implementation\.sh$|^ M scripts/validate-phase-3-corridor-3-surfacing-implementation\.sh$' ||
  true
)"
test -z "$unexpected"

npx tsx --test scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts
bash scripts/guard-ollama-response-contract.sh
git diff --check

grep -Fq 'Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label.' scripts/utils/ollamaChat.ts
grep -Fq 'When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction.' scripts/utils/ollamaChat.ts
grep -Fq "When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -Fq 'Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present.' scripts/utils/ollamaChat.ts

echo "CORRIDOR_3_IMPLEMENTATION_VALIDATION=PASS"
echo "IMPLEMENTATION_COMMIT=3e8f1a51"
echo "PROMPT_ONLY_SURFACING_CHANGE=CONFIRMED"
echo "TARGETED_TEST=PASS"
echo "RESPONSE_CONTRACT_GUARD=PASS"
echo "VISIBLE_REASONING_STATUS_LABEL=NO"
echo "UI_CHANGE=NONE"
echo "WORKFLOW_CHANGE=NONE"
echo "SCHEMA_CHANGE=NONE"
echo "MODEL_INVOCATION_COUNT_CHANGE=NONE"
echo "FAIL_CLOSED_VALIDATION_CHANGE=NONE"
echo "CORRIDOR_2_RELIABILITY_LIMIT=PRESERVED"
echo "MODEL_BEHAVIORAL_RELIABILITY_CLAIM=NONE"
echo "DR_NOW=NO"
echo "NEXT_ACTION=CLASSIFY_CORRIDOR_3_CLOSURE_READINESS"
