#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE CONVERSATION ENGINE GENERATION STABILITY MILESTONE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CLOSURE-READINESS CHECKPOINT ==="
expected_head="ae90035d"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches generation-stability closure-readiness checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-conversation-engine-generation-stability-milestone\.sh$|^ M scripts/close-conversation-engine-generation-stability-milestone\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLOSURE_READINESS_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY FINAL GOVERNING EVIDENCE ==="

grep -nE \
  'MILESTONE_CAN_CLOSE=|YES|CLOSURE_CLASSIFICATION=|COMPLETE_WITH_PRODUCTION_GENERATION_INSTABILITY_EXPLICITLY_ESTABLISHED|UNRESOLVED_CONDITION_BLOCKS_MILESTONE_CLOSURE=|NO|UNQUALIFIED_PRODUCTION_STABLE=|PHASE_3_CLOSURE_READINESS=|READY|CLOSE_CONVERSATION_ENGINE_GENERATION_STABILITY_MILESTONE' \
  scripts/classify-phase-3-generation-stability-closure-readiness.sh

grep -nE \
  'PHASE_2_DISPOSITION=|COMPLETE_WITH_PRODUCTION_GENERATION_POLICY_DEFERRED|PHASE_2_STATUS=|COMPLETE' \
  scripts/classify-generation-policy-and-control-boundary-phase-disposition.sh

grep -nE \
  'PHASE_3_PRODUCTION_STABILITY_RESULT=|UNSTABLE|PHASE_3_REPEATED_VALIDATION_STATUS=|COMPLETE' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

grep -nE \
  'FAIL_CLOSED_CONTRACT_PRESERVATION=|COMPLETE' \
  scripts/classify-phase-3-fail-closed-contract-preservation.sh

grep -nE \
  'SINGLE_OLLAMA_INVOCATION_PRESERVATION=|COMPLETE' \
  scripts/classify-phase-3-single-ollama-invocation-preservation.sh

grep -nE \
  'REGRESSION_SET_RESULT=|PASS|TOTAL_ASSERTIONS=|37|TOTAL_FAIL=|0|PRODUCTION_REGRESSION_VALIDATION=|COMPLETE' \
  scripts/classify-phase-3-existing-regression-validation-result.sh

echo "FINAL_GOVERNING_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY CURRENT PRODUCTION BASELINE ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"

if [[ "$production_call_count" -ne 1 ]]; then
  echo "STOP: production workflow no longer contains exactly one ollamaChat invocation."
  exit 2
fi

echo "CURRENT_PRODUCTION_BASELINE=CONFIRMED"

echo
echo "=== FINAL MILESTONE CLOSURE ==="

cat <<'MAP'
MILESTONE=
  CONVERSATION_ENGINE_GENERATION_STABILITY

MILESTONE_STATUS=
  COMPLETE

CLOSURE_CLASSIFICATION=
  COMPLETE_WITH_PRODUCTION_GENERATION_INSTABILITY_EXPLICITLY_ESTABLISHED

PHASE_1=
  PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
  COMPLETE

PHASE_1_FINAL_RESULT=
  MATERIAL_UNSEEDED_GENERATION_INSTABILITY_ESTABLISHED

PHASE_2=
  GENERATION_POLICY_AND_CONTROL_BOUNDARY
  COMPLETE

PHASE_2_FINAL_RESULT=
  COMPLETE_WITH_PRODUCTION_GENERATION_POLICY_DEFERRED

PHASE_3=
  PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
  COMPLETE

PHASE_3_FINAL_RESULT=
  PRODUCTION_GENERATION_UNSTABLE_ON_ESTABLISHED_ADAPTIVE_DETAIL_SURFACE

PHASE_3_SAMPLE=
  TOTAL_RUNS=10
  FIXTURE_SEMANTIC_PASS_RUNS=0
  FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8
  FIXTURE_SEMANTIC_FAILURE_RUNS=2
  UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3

FAIL_CLOSED_CONTRACT=
  PRESERVED

SINGLE_OLLAMA_INVOCATION=
  PRESERVED

DETERMINISTIC_REGRESSION_VALIDATION=
  PASS_37_OF_37

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

CURRENT_PRODUCTION_GENERATION_POLICY=
  UNSEEDED
  NO_EXPLICIT_TEMPERATURE
  NO_EXPLICIT_TOP_P
  NO_EXPLICIT_TOP_K
  OLLAMA_AND_MODEL_DEFAULTS

PRODUCTION_GENERATION_POLICY_CHANGE=
  NONE

PRODUCTION_IMPLEMENTATION=
  NONE

PRODUCTION_CHANGE=
  NONE

UNQUALIFIED_PRODUCTION_STABLE=
  NO

UNRESOLVED_PRODUCTION_CONDITION=
  GENERATION_INSTABILITY_REMAINS

UNRESOLVED_CONDITION_DISPOSITION=
  DEFERRED_PRODUCTION_POLICY_CONCERN

PRODUCTION_GENERATION_POLICY_PROMOTION=
  NOT_AUTHORIZED

FIXED_SEED_PROMOTION=
  NOT_AUTHORIZED

VALIDATOR_RELAXATION=
  NOT_AUTHORIZED

RETRY_OR_MULTI_INVOCATION=
  NOT_AUTHORIZED

MODEL_CHANGE=
  NOT_AUTHORIZED

MILESTONE_OBJECTIVES_SATISFIED=
  YES

RATIONALE=
  The milestone successfully characterized current ordinary production
  generation behavior rather than forcing an unsupported stability result.

  Repeated unseeded validation independently confirmed material production
  generation instability on the established Adaptive Detail surface.

  Deterministic fail-closed enforcement remained correct.

  The one-Ollama-invocation invariant remained preserved.

  The selected deterministic repository regression surface passed 37 of 37
  assertions.

  No production runtime regression caused by the milestone was established.

  Phase 2 correctly deferred production generation-policy promotion because
  wider semantic preservation and production policy authority remain
  unresolved.

  The remaining production-generation instability is therefore an explicit
  deferred condition, not an unclassified blocker.

GENERATION_STABILITY_MILESTONE=
  CLOSED

NEXT_MILESTONE=
  NOT_CLASSIFIED_BY_THIS_CLOSURE

NEXT_ACTION=
  RECONCILE_POST_GENERATION_STABILITY_PROGRAM_STATE
MAP

echo
echo "=== VERIFY CLOSURE-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-conversation-engine-generation-stability-milestone\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside milestone-closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLOSURE_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/close-conversation-engine-generation-stability-milestone.sh
git diff --cached --check
git commit -m "Close conversation engine generation stability milestone"
git push
