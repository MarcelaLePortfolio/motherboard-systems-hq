#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION CONTROL SEMANTIC PRESERVATION CORRIDOR DISPOSITION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REQUIRED CHECKPOINT ==="
expected_head="00c62177"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches source-excerpt seeded baseline comparison checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-control-semantic-preservation-corridor-disposition\.sh$|^ M scripts/classify-generation-control-semantic-preservation-corridor-disposition\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REQUIRED_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING EVIDENCE ==="

grep -nE \
  'FIXED_SEED_SPECIFIC_REGRESSION=|WIDER_SEMANTIC_PRESERVATION_EVIDENCE=|BLOCKED_BY_INSUFFICIENT_ADMISSIBLE_REPOSITORY_LIVE_FIXTURES|NEW_SEEDED_FIXTURE_AUTHORIZED=NO|PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO|CLASSIFY_GENERATION_CONTROL_SEMANTIC_PRESERVATION_CORRIDOR_DISPOSITION' \
  scripts/classify-source-excerpt-seeded-vs-unseeded-baseline-comparison.sh

grep -nE \
  'DIAGNOSTIC_CANDIDATE_RESULT=SUPPORTED|PRIMARY_CRITERION|EXACT_REPEATABILITY|PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh \
  scripts/classify-fixed-seed-diagnostic-result.sh \
  2>/dev/null || true

echo "GOVERNING_EVIDENCE_PRESENT=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== VERIFY DETERMINISTIC VALIDATORS REMAIN PRESENT ==="

grep -nF \
  'Ollama returned a selected context segment that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Ollama returned a conversation support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Ollama returned a project-context support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

echo "FAIL_CLOSED_VALIDATORS=PRESENT"

echo
echo "=== CORRIDOR DISPOSITION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=CORRIDOR_DISPOSITION

KNOWN_FAILURE_SURFACE_RESULT=
  FIXED_SEED_DIAGNOSTIC_SUPPORTED

  On the established Adaptive Detail failure fixture, fixed validation seed
  424242 produced the bounded 10/10 semantic-pass result, zero fail-closed
  rejections, zero child-derived invalid parent-support identities, and exact
  output repeatability.

WIDER_SEMANTIC_PRESERVATION_RESULT=
  NOT_ESTABLISHED

WHY_NOT_ESTABLISHED=
  The additional repository live fixtures selected for wider semantic
  comparison do not currently provide admissible discriminating evidence.

  Reasoning / Explanation:
    seeded and unseeded forms both fail the current selected-context contract.

  Structured Evidence:
    seeded and unseeded forms both fail the current selected-context contract.

  Source Excerpt First:
    seeded and unseeded forms both fail the current conversation-support
    provenance contract.

CAUSAL_INTERPRETATION=
  No wider failure observed so far is established as a regression caused by
  validationGenerationSeed=424242.

  However, absence of a demonstrated regression is not equivalent to evidence
  that the fixed seed preserves the wider semantic contract.

FIXED_SEED_CANDIDATE_STATUS=
  DIAGNOSTICALLY_SUPPORTED_FOR_KNOWN_FAILURE_SURFACE
  NOT_DISQUALIFIED_BY_WIDER_COMPARISONS
  NOT_PROVEN_WIDER_SEMANTICALLY_SAFE
  NOT_READY_FOR_PRODUCTION_PROMOTION

REPOSITORY_EVIDENCE_LIMIT=
  INSUFFICIENT_ADMISSIBLE_LIVE_FIXTURES_FOR_WIDER_SEMANTIC_PRESERVATION

CORRIDOR_DISPOSITION=
  DEFER_PRODUCTION_PROMOTION

  Do not continue creating seed-only fixtures merely to search for passing
  evidence.

  Do not repair unrelated historical fixtures inside this corridor solely to
  unblock fixed-seed promotion.

  Preserve the current diagnostic evidence and treat wider semantic
  preservation as unresolved.

DETERMINISTIC_VALIDATOR=
  PRESERVE

FAIL_CLOSED_BEHAVIOR=
  PRESERVE

NEW_SEEDED_FIXTURE_AUTHORIZED=
  NO

FIXTURE_REPAIR_AUTHORIZED=
  NO

PROMPT_CHANGE_AUTHORIZED=
  NO

VALIDATOR_RELAXATION_AUTHORIZED=
  NO

SEED_CHANGE_AUTHORIZED=
  NO

TEMPERATURE_EXPERIMENT_AUTHORIZED=
  NO

TOP_P_EXPERIMENT_AUTHORIZED=
  NO

TOP_K_EXPERIMENT_AUTHORIZED=
  NO

MODEL_CHANGE_AUTHORIZED=
  NO

RETRY_OR_MULTI_INVOCATION_AUTHORIZED=
  NO

PRODUCTION_SEED_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

SEMANTIC_PRESERVATION_CORRIDOR_STATUS=
  COMPLETE_WITH_UNRESOLVED_PRODUCTION_PROMOTION_BOUNDARY

PHASE_2_STATUS=
  CONTINUE_TO_POLICY_OWNERSHIP_AND_CONTROL_BOUNDARY_CLASSIFICATION

NEXT_ACTION=
  CLASSIFY_REQUEST_SCOPED_VS_SHARED_GENERATION_POLICY_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-control-semantic-preservation-corridor-disposition\.sh$' ||
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

git add scripts/classify-generation-control-semantic-preservation-corridor-disposition.sh
git diff --cached --check
git commit -m "Classify generation control semantic preservation disposition"
git push
