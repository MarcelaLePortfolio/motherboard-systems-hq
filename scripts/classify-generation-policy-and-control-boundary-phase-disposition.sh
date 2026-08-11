#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION POLICY AND CONTROL BOUNDARY PHASE DISPOSITION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CONFIGURATION/ROLLBACK CHECKPOINT ==="
expected_head="42c6a586"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches generation-policy rollback checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-policy-and-control-boundary-phase-disposition\.sh$|^ M scripts/classify-generation-policy-and-control-boundary-phase-disposition\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CONFIGURATION_ROLLBACK_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PHASE 2 GOVERNING EVIDENCE ==="

grep -nE \
  'SEMANTIC_PRESERVATION_CORRIDOR_STATUS=|DEFER_PRODUCTION_PROMOTION|NOT_READY_FOR_PRODUCTION_PROMOTION' \
  scripts/classify-generation-control-semantic-preservation-corridor-disposition.sh

grep -nE \
  'REQUEST_SCOPED_DIAGNOSTIC_CONTROL_ESTABLISHED|SHARED_PRODUCTION_POLICY_NOT_ESTABLISHED' \
  scripts/classify-request-scoped-vs-shared-generation-policy-boundary.sh

grep -nE \
  'DIAGNOSTIC_AUTHORITY_ESTABLISHED|PRODUCTION_POLICY_AUTHORITY_NOT_YET_ESTABLISHED|PRODUCTION_IMPLEMENTATION_AUTHORITY_NOT_GRANTED' \
  scripts/classify-generation-control-authorization-and-ownership-boundary.sh

grep -nE \
  'CONFIGURATION_REQUIREMENTS_ESTABLISHED|OBSERVABILITY_REQUIREMENTS_ESTABLISHED|ROLLBACK_REQUIREMENTS_ESTABLISHED|IMPLEMENTATION_NOT_AUTHORIZED|READY_FOR_PHASE_2_DISPOSITION_CLASSIFICATION' \
  scripts/classify-generation-policy-configuration-and-rollback-boundary.sh

echo "PHASE_2_GOVERNING_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY CURRENT PRODUCTION BASELINE ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains an explicit generation control."
  exit 2
fi

echo "PRODUCTION_EXPLICIT_GENERATION_CONTROL=ABSENT"

echo
echo "=== PHASE 2 DISPOSITION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
UNIT=PHASE_DISPOSITION

PHASE_2_FINDINGS=
  1. The existing generation-control seam is request-scoped and diagnostic.

  2. Fixed validation seed 424242 is diagnostically supported on the known
     Adaptive Detail failure surface.

  3. Wider semantic preservation is not established because the additional
     repository live fixtures do not currently provide admissible
     discriminating seeded-versus-unseeded evidence.

  4. No fixed-seed-specific wider regression has been established.

  5. No shared production generation-policy layer currently exists.

  6. Production policy authority and implementation authority are not
     established.

  7. Configuration, observability, and rollback requirements for any future
     shared production generation policy are now classified.

CURRENT_PRODUCTION_GENERATION_POLICY=
  UNSEEDED
  NO_EXPLICIT_TEMPERATURE
  NO_EXPLICIT_TOP_P
  NO_EXPLICIT_TOP_K
  OLLAMA_AND_MODEL_DEFAULTS

REQUEST_SCOPED_DIAGNOSTIC_CONTROL=
  PRESERVE

FIXED_SEED_DIAGNOSTIC_RESULT=
  SUPPORTED_FOR_KNOWN_FAILURE_SURFACE

WIDER_SEMANTIC_PRESERVATION=
  UNRESOLVED

SHARED_PRODUCTION_POLICY=
  NOT_ESTABLISHED

PRODUCTION_POLICY_AUTHORITY=
  NOT_ESTABLISHED

PRODUCTION_IMPLEMENTATION_AUTHORITY=
  NOT_GRANTED

PRODUCTION_SEED=
  NOT_AUTHORIZED

PRODUCTION_TEMPERATURE=
  NOT_AUTHORIZED

PRODUCTION_TOP_P=
  NOT_AUTHORIZED

PRODUCTION_TOP_K=
  NOT_AUTHORIZED

RETRY_OR_MULTI_INVOCATION_POLICY=
  NOT_AUTHORIZED

MODEL_CHANGE=
  NOT_AUTHORIZED

VALIDATOR_RELAXATION=
  NOT_AUTHORIZED

PHASE_2_DISPOSITION=
  COMPLETE_WITH_PRODUCTION_GENERATION_POLICY_DEFERRED

RATIONALE=
  Phase 2 has answered the policy-boundary questions required by the current
  repository evidence without introducing a speculative production control.

  The existing diagnostic seam remains useful and bounded.

  Production promotion is deferred because wider semantic preservation and
  production policy ownership remain unresolved.

  Those unresolved matters are explicit constraints rather than blockers to
  completing the boundary-classification phase itself.

PHASE_2_IMPLEMENTATION_RESULT=
  NO_PRODUCTION_IMPLEMENTATION_REQUIRED

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

PHASE_2_STATUS=
  COMPLETE

NEXT_PHASE=
  PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE

NEXT_PHASE_NUMBER=
  3

NEXT_ACTION=
  CLASSIFY_PHASE_3_PRODUCTION_STABILITY_VALIDATION_STARTING_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-policy-and-control-boundary-phase-disposition\.sh$' ||
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

git add scripts/classify-generation-policy-and-control-boundary-phase-disposition.sh
git diff --cached --check
git commit -m "Classify generation policy phase disposition"
git push
