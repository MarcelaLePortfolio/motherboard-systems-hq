#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY DIAGNOSTIC CONTROLS COMPLETENESS ==="

expected_head="58fa91ea"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Diagnostic Controls checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-diagnostic-controls-completeness\.sh$|^ M scripts/classify-diagnostic-controls-completeness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

grep -q 'REQUEST_SCOPED_VALIDATION_ONLY_FIXED_SEED' \
  scripts/classify-existing-diagnostic-controls-and-boundaries.sh
grep -q 'EXACT_REPEATABILITY_FOR_BOUNDED_IDENTICAL_DIAGNOSTIC_GENERATION' \
  scripts/classify-existing-diagnostic-controls-and-boundaries.sh
grep -q 'CAN_COMPARE_CONTROLLED_REPEATABLE_GENERATION_AGAINST_ORDINARY_UNSEEDED_VARIANCE' \
  scripts/classify-existing-diagnostic-controls-and-boundaries.sh
grep -q 'PRODUCTION_GENERATION_POLICY_CHANGE=' \
  scripts/classify-existing-diagnostic-controls-and-boundaries.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED

CURRENT_CORRIDOR=
DIAGNOSTIC_CONTROLS

GENERATION_VARIANCE=
COMPLETE

FAILURE_CHARACTERIZATION=
COMPLETE

DIAGNOSTIC_CONTROL_AVAILABLE=
YES

DIAGNOSTIC_CONTROL=
REQUEST_SCOPED_VALIDATION_ONLY_FIXED_SEED

CONTROLLED_REPEATABILITY=
ESTABLISHED

UNSEEDED_VS_CONTROLLED_COMPARISON=
SUPPORTED

PRODUCTION_POLICY_SEPARATION=
PRESERVED

TEMPERATURE_CONTROL_REQUIRED_FOR_CORRIDOR_COMPLETENESS=
NO

TOP_P_CONTROL_REQUIRED_FOR_CORRIDOR_COMPLETENESS=
NO

TOP_K_CONTROL_REQUIRED_FOR_CORRIDOR_COMPLETENESS=
NO

ADDITIONAL_DIAGNOSTIC_CONTROL_REQUIRED=
NOT_ESTABLISHED

DIAGNOSTIC_CONTROLS_OBJECTIVE=
ESTABLISH_A_BOUNDED_CONTROL_CAPABLE_OF_DISTINGUISHING_ORDINARY_UNSEEDED_VARIANCE_FROM_CONTROLLED_REPEATABLE_GENERATION_WITHOUT_CHANGING_PRODUCTION_POLICY

DIAGNOSTIC_CONTROLS_OBJECTIVE_SATISFIED=
YES

DIAGNOSTIC_CONTROLS_CLOSURE_READINESS=
READY

CORRIDOR_CLOSURE=
NO

CORRIDOR_CLOSE_COMMIT_AUTHORIZED=
NO_PENDING_USER_DR

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY_CHANGE=
NONE

PRODUCTION_CHANGE=
NONE

DIAGNOSTIC_CONTROLS=
ACTIVE

STABILITY_DETERMINATION=
PENDING

NEXT_ACTION=
STOP_FOR_USER_DR_BEFORE_CLOSING_DIAGNOSTIC_CONTROLS
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-diagnostic-controls-completeness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Diagnostic Controls completeness scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

git diff --check
