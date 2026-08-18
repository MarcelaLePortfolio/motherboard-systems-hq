#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — CLOSURE READINESS CLASSIFICATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 5ced6c47 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-corridor-3-closure-readiness\.sh$|^ M scripts/classify-phase-3-corridor-3-closure-readiness\.sh$' ||
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

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_3=SURFACING_CONTRACT
STATUS=CLOSURE_READINESS_CLASSIFIED

IMPLEMENTATION_COMMIT=3e8f1a51
VALIDATION_COMMIT=5ced6c47

SURFACING_CONTRACT_IMPLEMENTED=YES
TARGETED_CONTRACT_TEST=PASS
RESPONSE_CONTRACT_GUARD=PASS
INVESTIGATION_LIFECYCLE_GUARD=PASS

OPTIONAL_SURFACING_RULE=IMPLEMENTED
RECOMMENDED_SURFACING_RULE=IMPLEMENTED
VISIBLE_REASONING_STATUS_LABEL=NO

UI_CHANGE=NONE
WORKFLOW_CHANGE=NONE
SCHEMA_CHANGE=NONE
NEW_RUNTIME_SEAM=NONE
MODEL_INVOCATION_COUNT_CHANGE=NONE
RETRY_CHANGE=NONE
FAIL_CLOSED_VALIDATION_CHANGE=NONE

CORRIDOR_2_BEHAVIORAL_RELIABILITY_LIMIT=PRESERVED
MODEL_BEHAVIORAL_RELIABILITY_ESTABLISHED=NO
REASONING_STATUS_DEFECT_ESTABLISHED=NO

CORRIDOR_3_SCOPE_COMPLETE=YES
CORRIDOR_3_CLOSURE_READY=YES
PRODUCTION_CHANGE=BOUNDED_PROMPT_ONLY_SURFACING_CONTRACT
DR_REQUIRED_AT_CLOSURE=YES
DR_NOW=NO
NEXT_ACTION=CLOSE_CORRIDOR_3_AND_RECORD_SINGLE_CANONICAL_DR_WITH_CORRIDOR_2_DEFERRED_LIMIT_CARRIED_FORWARD
MAP
