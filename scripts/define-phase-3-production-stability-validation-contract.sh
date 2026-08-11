#!/usr/bin/env bash
set -euo pipefail

echo "=== DEFINE PHASE 3 PRODUCTION STABILITY VALIDATION CONTRACT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY PHASE 3 STARTING BOUNDARY CHECKPOINT ==="
expected_head="7d9e1d77"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 starting-boundary checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/define-phase-3-production-stability-validation-contract\.sh$|^ M scripts/define-phase-3-production-stability-validation-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_3_STARTING_BOUNDARY_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING STARTING BOUNDARY ==="
grep -nE \
  'PHASE_3_STARTING_BOUNDARY=|PRODUCTION_STABILITY_ACCEPTANCE_BOUNDARY=|MUST_BE_CLASSIFIED_BEFORE_NEW_REPEATED_SAMPLE|NEXT_CORRIDOR=|PRODUCTION_STABILITY_VALIDATION_CONTRACT|DEFINE_PHASE_3_PRODUCTION_STABILITY_VALIDATION_CONTRACT' \
  scripts/classify-phase-3-production-stability-validation-starting-boundary.sh

echo "GOVERNING_STARTING_BOUNDARY=CONFIRMED"

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
  echo "STOP: expected exactly one production ollamaChat invocation."
  exit 2
fi

echo "PRODUCTION_BASELINE=CONFIRMED"

echo
echo "=== DEFINE VALIDATION CONTRACT ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=PRODUCTION_STABILITY_VALIDATION_CONTRACT
UNIT=VALIDATION_CONTRACT

PRODUCTION_BASELINE=
  UNSEEDED
  NO_EXPLICIT_TEMPERATURE
  NO_EXPLICIT_TOP_P
  NO_EXPLICIT_TOP_K
  ONE_OLLAMA_INVOCATION
  DETERMINISTIC_FAIL_CLOSED_VALIDATION_PRESERVED

VALIDATION_OBJECTIVE=
  Characterize the stability of the current ordinary production generation
  behavior without changing the generation policy.

PRIMARY_VALIDATION_SURFACE=
  EXISTING_ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE_FIXTURE

RATIONALE=
  This fixture is the already-established production-relevant semantic surface
  on which Phase 1 observed material unseeded acceptance instability.

  Reusing it preserves continuity with the original production-stability
  finding and avoids inventing a new acceptance surface.

REPEATED_SAMPLE_REQUIRED=
  YES

REPEATED_SAMPLE_MODE=
  UNSEEDED_ONLY

SAMPLE_SIZE=
  10_SEQUENTIAL_IDENTICAL_INVOCATIONS

RETRY_POLICY=
  NO_RETRY_OF_FAILED_RUN

SEED=
  ABSENT

TEMPERATURE=
  UNCHANGED

TOP_P=
  UNCHANGED

TOP_K=
  UNCHANGED

MODEL=
  UNCHANGED

PROMPT=
  UNCHANGED

VALIDATORS=
  UNCHANGED

OLLAMA_INVOCATION_COUNT=
  ONE_PER_RUN

PRIMARY_MEASURES=
  - total runs;
  - semantic-pass runs;
  - deterministic fail-closed/runtime rejections;
  - fixture semantic failures after successful return;
  - exact-output fingerprints;
  - observed rejection signatures.

STABILITY_CLASSIFICATION_RULE=
  STABLE requires all 10 runs to satisfy the established fixture semantic
  contract with zero deterministic rejection and zero fixture semantic
  failure.

  Any deterministic rejection or semantic failure prevents an unqualified
  STABLE classification.

FAIL_CLOSED_CLASSIFICATION_RULE=
  If semantic generation violates supplied-context or provenance contracts and
  deterministic validation rejects the response, record that as production
  generation instability with correct fail-closed enforcement, not validator
  failure.

EXACT_REPEATABILITY=
  OBSERVATIONAL_ONLY

  Exact prose repeatability is not required for semantic stability.

COMPARISON_RULE=
  Compare the Phase 3 sample against the preserved Phase 1 unseeded result.

  Do not substitute seeded diagnostic evidence for production evidence.

POSSIBLE_RESULTS=
  STABLE
  STABLE_WITH_EXPLICIT_LIMITATION
  UNSTABLE_BUT_CORRECTLY_FAIL_CLOSED
  BLOCKED

PRODUCTION_POLICY_DEFERRED=
  YES

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_CHANGE=
  NONE

VALIDATION_CONTRACT_STATUS=
  DEFINED

NEXT_ACTION=
  CLASSIFY_PHASE_3_REPEATED_UNSEEDED_VALIDATION_FIXTURE_AND_RUNNER
MAP

echo
echo "=== VERIFY CONTRACT-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/define-phase-3-production-stability-validation-contract\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside validation-contract scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CONTRACT_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/define-phase-3-production-stability-validation-contract.sh
git diff --cached --check
git commit -m "Define Phase 3 production stability validation contract"
git push
