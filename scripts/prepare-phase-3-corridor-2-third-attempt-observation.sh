#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — PREPARE THIRD ATTEMPT OBSERVATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 029b1561 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/prepare-phase-3-corridor-2-third-attempt-observation\.sh$|^ M scripts/prepare-phase-3-corridor-2-third-attempt-observation\.sh$' ||
  true
)"
test -z "$unexpected"

grep -q 'observeParsedSelectedContextSegments' scripts/utils/ollamaChat.ts
grep -q 'observeValidatedSelectedContextSegments' scripts/utils/ollamaChat.ts
grep -q 'Ollama returned a selected context segment that was not supplied in this invocation.' scripts/utils/ollamaChat.ts

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_2=BEHAVIOR_VALIDATION
STATUS=ACTIVE
VALIDATION_ONLY_OBSERVER_IMPLEMENTED=YES
IMPLEMENTATION_COMMIT=029b1561
OBSERVER_TEST=PASS
RESPONSE_CONTRACT_GUARD=PASS
FAIL_CLOSED_MEMBERSHIP_VALIDATION=PRESERVED
PRODUCTION_SEMANTIC_CHANGE=NONE
FAILED_BEHAVIOR_VALIDATION_ATTEMPTS=2
THIRD_BEHAVIOR_VALIDATION_ATTEMPT=NOT_STARTED
NEXT_HYPOTHESIS=USE_PRE_MEMBERSHIP_OBSERVER_TO_CAPTURE_THE_EXACT_MODEL_AUTHORED_SELECTED_CONTEXT_IDENTITY_BEFORE_ANY_THIRD_BEHAVIOR_VALIDATION_RUN
THIRD_ATTEMPT_PURPOSE=DIAGNOSE_THE_PREVIOUS_REJECTION_CAUSE_AND_ONLY_THEN_DETERMINE_IF_A_THIRD_BEHAVIOR_VALIDATION_RUN_IS_JUSTIFIED
DR_NOW=NO
NEXT_ACTION=BUILD_SINGLE_DIAGNOSTIC_OBSERVATION_RUN
MAP
