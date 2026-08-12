#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION STABILITY PHASE AND MILESTONE DISPOSITION ==="

expected_head="bcca5b7c"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches expected Stability Determination closure checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-stability-phase-and-milestone-disposition\.sh$|^ M scripts/classify-generation-stability-phase-and-milestone-disposition\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'PHASE_CORRIDORS_COMPLETE=' \
  scripts/close-stability-determination-corridor.sh

grep -q '4_OF_4' \
  scripts/close-stability-determination-corridor.sh

grep -q 'UNQUALIFIED_PRODUCTION_STABILITY_NOT_ESTABLISHED' \
  scripts/classify-production-stability-from-established-evidence.sh

grep -q 'MATERIAL_GENERATION_INSTABILITY_ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE' \
  scripts/classify-production-stability-from-established-evidence.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED

GENERATION_VARIANCE=
COMPLETE

FAILURE_CHARACTERIZATION=
COMPLETE

DIAGNOSTIC_CONTROLS=
COMPLETE

STABILITY_DETERMINATION=
COMPLETE

PHASE_CORRIDORS_COMPLETE=
4_OF_4

PHASE_OBJECTIVE=
CHARACTERIZE_PRODUCTION_GENERATION_VARIANCE_FAILURE_MODES_DIAGNOSTIC_CONTROLS_AND_STABILITY_STATE

PHASE_OBJECTIVE_SATISFIED=
YES

PHASE_CLOSURE_READINESS=
READY

PHASE_CLOSURE=
NOT_PERFORMED

PRODUCTION_STABILITY=
NOT_ESTABLISHED

MATERIAL_GENERATION_INSTABILITY=
ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE

FAIL_CLOSED_VALIDATION=
PRESERVED

DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED

VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY_REMEDY=
NOT_ESTABLISHED

MILESTONE_CLOSURE_READINESS=
NOT_YET_ESTABLISHED

MILESTONE_CLOSURE=
NOT_PERFORMED

NEXT_CORRIDOR=
NOT_ESTABLISHED

NEW_CORRIDOR_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO

NEXT_ACTION=
CONSULT_WITH_USER_BEFORE_CLOSING_PHASE_OR_DEFINING_ANY_SUCCESSOR_PHASE_OR_CORRIDOR
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-stability-phase-and-milestone-disposition\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside phase/milestone disposition classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
