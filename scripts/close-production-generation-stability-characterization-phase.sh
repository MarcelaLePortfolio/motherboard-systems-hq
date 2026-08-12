#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE PRODUCTION GENERATION STABILITY CHARACTERIZATION PHASE ==="

expected_head="74cc7c70"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches phase-disposition checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-production-generation-stability-characterization-phase\.sh$|^ M scripts/close-production-generation-stability-characterization-phase\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'PHASE_CLOSURE_READINESS=' \
  scripts/classify-generation-stability-phase-and-milestone-disposition.sh

grep -q 'READY' \
  scripts/classify-generation-stability-phase-and-milestone-disposition.sh

grep -q '4_OF_4' \
  scripts/classify-generation-stability-phase-and-milestone-disposition.sh

grep -q 'UNQUALIFIED_PRODUCTION_STABILITY_NOT_ESTABLISHED' \
  scripts/classify-production-stability-from-established-evidence.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

MILESTONE_STATUS=
OPEN

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

PHASE_STATUS=
CLOSED

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

PHASE_OBJECTIVE_SATISFIED=
YES

PHASE_RESULT=
PRODUCTION_GENERATION_BEHAVIOR_CHARACTERIZED_WITH_MATERIAL_INSTABILITY_ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE

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

PRODUCTION_GENERATION_POLICY_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

MILESTONE_CLOSURE=
NOT_PERFORMED

MILESTONE_CLOSURE_READINESS=
NOT_YET_ESTABLISHED

SUCCESSOR_PHASE=
NOT_ESTABLISHED

SUCCESSOR_CORRIDOR=
NOT_ESTABLISHED

SUCCESSOR_PHASE_OR_CORRIDOR_AUTHORIZED=
NO

NEXT_ACTION=
STOP_FOR_USER_CONSULTATION_BEFORE_DEFINING_ANY_SUCCESSOR_PHASE_OR_CORRIDOR
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-production-generation-stability-characterization-phase\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside phase-closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
