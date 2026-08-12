#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE DIAGNOSTIC CONTROLS CORRIDOR ==="

expected_head="d67ab828"
required_dr="20260812_005014"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Diagnostic Controls closure-readiness checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-diagnostic-controls-corridor\.sh$|^ M scripts/close-diagnostic-controls-corridor\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

grep -q 'DIAGNOSTIC_CONTROLS_CLOSURE_READINESS=' \
  scripts/classify-diagnostic-controls-completeness.sh
grep -q '^READY$' \
  <(awk '/DIAGNOSTIC_CONTROLS_CLOSURE_READINESS=/{getline; print}' \
    scripts/classify-diagnostic-controls-completeness.sh)
grep -q 'REQUEST_SCOPED_VALIDATION_ONLY_FIXED_SEED' \
  scripts/classify-existing-diagnostic-controls-and-boundaries.sh
grep -q 'CONTROLLED_REPEATABILITY=' \
  scripts/classify-diagnostic-controls-completeness.sh

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

DIAGNOSTIC_CONTROLS_DR=
20260812_005014

DIAGNOSTIC_CONTROLS_RESULT=
BOUNDED_VALIDATION_ONLY_FIXED_SEED_CONTROL_CONFIRMED_SUFFICIENT_FOR_DIAGNOSTIC_COMPARISON

DIAGNOSTIC_CONTROL=
REQUEST_SCOPED_VALIDATION_ONLY_FIXED_SEED

FIXED_SEED=
424242

CONTROLLED_REPEATABILITY=
ESTABLISHED

UNSEEDED_VS_CONTROLLED_COMPARISON=
SUPPORTED

PRODUCTION_POLICY_SEPARATION=
PRESERVED

ADDITIONAL_DIAGNOSTIC_CONTROL_REQUIRED=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

DIAGNOSTIC_CONTROLS_CORRIDOR=
CLOSED

NEXT_CORRIDOR=
STABILITY_DETERMINATION

STABILITY_DETERMINATION=
NEXT

NEXT_ACTION=
BEGIN_STABILITY_DETERMINATION_CORRIDOR
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-diagnostic-controls-corridor\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Diagnostic Controls closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

git diff --check
