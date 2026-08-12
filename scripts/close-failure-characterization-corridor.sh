#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE FAILURE CHARACTERIZATION CORRIDOR ==="

expected_head="397b4ce6"
required_dr="20260812_003537"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Failure Characterization closure-readiness checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-failure-characterization-corridor\.sh$|^ M scripts/close-failure-characterization-corridor\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

grep -q 'FAILURE_CHARACTERIZATION_CLOSURE_READINESS=' \
  scripts/classify-failure-characterization-closure-readiness.sh
grep -q 'TWO_OBSERVED_FAILURE_CLASSES_ESTABLISHED' \
  scripts/classify-failure-characterization-observed-classes.sh
grep -q 'GENERATION_LAYER_SENSITIVITY_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED
GENERATION_VARIANCE=
COMPLETE
GENERATION_VARIANCE_DR=
20260811_180840
FAILURE_CHARACTERIZATION=
COMPLETE
FAILURE_CHARACTERIZATION_DR=
20260812_003537
FAILURE_CHARACTERIZATION_RESULT=
OBSERVED_FAILURE_MODES_REPEATABILITY_AND_CAUSAL_BOUNDARY_CHARACTERIZED
GENERATION_LAYER_SENSITIVITY=
ESTABLISHED
DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED
VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED
ROOT_CAUSE=
NOT_FULLY_ESTABLISHED
PRODUCTION_REMEDY=
NOT_ESTABLISHED
IMPLEMENTATION_AUTHORIZED=
NO
PRODUCTION_CHANGE=
NONE
FAILURE_CHARACTERIZATION_CORRIDOR=
CLOSED
NEXT_CORRIDOR=
DIAGNOSTIC_CONTROLS
STABILITY_DETERMINATION=
PENDING
NEXT_ACTION=
BEGIN_DIAGNOSTIC_CONTROLS_CORRIDOR
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-failure-characterization-corridor\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Failure Characterization closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

git diff --check
