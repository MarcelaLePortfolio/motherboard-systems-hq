#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 PRODUCTION STABILITY VALIDATION STARTING BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY PHASE 2 CLOSURE CHECKPOINT ==="
expected_head="29922108"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 2 closure checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-production-stability-validation-starting-boundary\.sh$|^ M scripts/classify-phase-3-production-stability-validation-starting-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_2_CLOSURE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PHASE 2 DISPOSITION ==="
grep -nE \
  'PHASE_2_DISPOSITION=|COMPLETE_WITH_PRODUCTION_GENERATION_POLICY_DEFERRED|PHASE_2_STATUS=|NEXT_PHASE=|PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE|NEXT_ACTION=|CLASSIFY_PHASE_3_PRODUCTION_STABILITY_VALIDATION_STARTING_BOUNDARY' \
  scripts/classify-generation-policy-and-control-boundary-phase-disposition.sh

echo "PHASE_2_DISPOSITION=CONFIRMED"

echo
echo "=== VERIFY CURRENT PRODUCTION GENERATION BASELINE ==="

grep -n -A24 -B4 \
  'await ollamaChat(message' \
  server/matilda-chat-workflow.ts

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

echo "CURRENT_PRODUCTION_GENERATION_BASELINE=UNSEEDED_DEFAULTS"

echo
echo "=== VERIFY SINGLE OLLAMA INVOCATION SEAM ==="

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"

echo "PRODUCTION_OLLAMA_CALL_COUNT=$production_call_count"

if [[ "$production_call_count" -ne 1 ]]; then
  echo "STOP: expected exactly one production ollamaChat invocation."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_BASELINE=CONFIRMED"

echo
echo "=== VERIFY FAIL-CLOSED CONTRACT SURFACES ==="

grep -nF \
  'Ollama returned a selected context segment that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Ollama returned a conversation support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Ollama returned a project-context support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

echo "FAIL_CLOSED_CONTRACT_SURFACES=CONFIRMED"

echo
echo "=== INSPECT EXISTING PRODUCTION-STABILITY VALIDATION ASSETS ==="

find scripts -maxdepth 1 -type f \
  \( \
    -name '*production*stability*' -o \
    -name '*unseeded*' -o \
    -name '*generation*stability*' -o \
    -name '*conversation*engine*' \
  \) |
  sort

echo
echo "=== PHASE 3 STARTING BOUNDARY ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
PHASE_NUMBER=3
UNIT=STARTING_BOUNDARY_CLASSIFICATION

PHASE_2_STATUS=
  COMPLETE

PHASE_2_PRODUCTION_POLICY_RESULT=
  DEFERRED

PHASE_3_PURPOSE=
  Validate and close the milestone against the current ordinary production
  generation behavior without introducing a speculative generation policy.

PRODUCTION_BASELINE_UNDER_VALIDATION=
  UNSEEDED
  NO_EXPLICIT_TEMPERATURE
  NO_EXPLICIT_TOP_P
  NO_EXPLICIT_TOP_K
  OLLAMA_AND_MODEL_DEFAULTS

ONE_OLLAMA_INVOCATION=
  PRESERVE

DETERMINISTIC_FAIL_CLOSED_VALIDATION=
  PRESERVE

REQUEST_SCOPED_DIAGNOSTIC_SEED=
  PRESERVE_AS_DIAGNOSTIC_ONLY

PHASE_3_MUST_NOT=
  - introduce a production seed;
  - introduce temperature, top_p, or top_k production controls;
  - reopen fixed-seed promotion;
  - create new seeded fixtures merely to accumulate passing evidence;
  - relax provenance or selected-context validation;
  - add retries;
  - add a second Ollama invocation;
  - change the model;
  - change prompt semantics merely to improve stability metrics.

PHASE_3_CAN_VALIDATE=
  1. Production Stability Validation Contract
  2. Repeated Unseeded Behavioral Validation
  3. Fail-Closed Contract Preservation
  4. Single Ollama Invocation Preservation
  5. Production Regression Validation
  6. Generation Stability Closure Classification

PHASE_3_EVIDENCE_RULE=
  Validation must characterize the production behavior that actually exists.

  Diagnostic seeded evidence may be referenced as prior evidence but must not
  substitute for ordinary unseeded production validation.

PRODUCTION_STABILITY_ACCEPTANCE_BOUNDARY=
  MUST_BE_CLASSIFIED_BEFORE_NEW_REPEATED_SAMPLE

  Existing Phase 1 evidence already established material unseeded instability
  on the known Adaptive Detail fixture.

  Phase 3 must therefore define what final production-stability validation can
  legitimately conclude given that production policy remains intentionally
  unchanged.

CLOSURE_MAY_RESULT_IN=
  STABLE
  STABLE_WITH_EXPLICIT_LIMITATION
  UNSTABLE_BUT_CORRECTLY_FAIL_CLOSED
  BLOCKED
  DEFERRED_PRODUCTION_POLICY

CLOSURE_MUST_NOT_INVENT=
  A stability result unsupported by repeated current production evidence.

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

PHASE_3_STARTING_BOUNDARY=
  ESTABLISHED

NEXT_CORRIDOR=
  PRODUCTION_STABILITY_VALIDATION_CONTRACT

NEXT_ACTION=
  DEFINE_PHASE_3_PRODUCTION_STABILITY_VALIDATION_CONTRACT
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-production-stability-validation-starting-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-3-production-stability-validation-starting-boundary.sh
git diff --cached --check
git commit -m "Classify Phase 3 stability validation boundary"
git push
