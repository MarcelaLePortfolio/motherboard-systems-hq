#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY FAILURE CHARACTERIZATION CLOSURE READINESS ==="

expected_head="4fecd6fb"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Failure Characterization checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-failure-characterization-closure-readiness\.sh$|^ M scripts/classify-failure-characterization-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

grep -q 'TWO_OBSERVED_FAILURE_CLASSES_ESTABLISHED' \
  scripts/classify-failure-characterization-observed-classes.sh

grep -q 'FAILURE_PATTERN_REPEATED_BUT_EXACT_OUTPUT_NOT_STABLE' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh

grep -q 'GENERATION_LAYER_SENSITIVITY_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh

grep -q 'DETERMINISTIC_RUNTIME_REGRESSION_NOT_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh

grep -q 'VALIDATOR_MALFUNCTION_NOT_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED

CURRENT_CORRIDOR=
FAILURE_CHARACTERIZATION

GENERATION_VARIANCE=
COMPLETE

FAILURE_CLASSES=
ESTABLISHED

FAILURE_CLASS_1=
INVALID_MODEL_AUTHORED_PROJECT_CONTEXT_SUPPORT_PROVENANCE

FAILURE_CLASS_2=
SEMANTIC_ACCEPTANCE_FAILURE_AFTER_SUCCESSFUL_ADAPTER_RETURN

REPEATABILITY=
CHARACTERIZED

CAUSAL_BOUNDARY=
CHARACTERIZED

GENERATION_LAYER_SENSITIVITY=
ESTABLISHED

DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED

VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED

ROOT_CAUSE=
NOT_FULLY_ESTABLISHED

ROOT_CAUSE_REQUIRED_FOR_FAILURE_CHARACTERIZATION_CLOSURE=
NO

PRODUCTION_REMEDY=
NOT_ESTABLISHED

PRODUCTION_REMEDY_REQUIRED_FOR_FAILURE_CHARACTERIZATION_CLOSURE=
NO

FAILURE_CHARACTERIZATION_OBJECTIVE=
CHARACTERIZE_OBSERVED_FAILURE_MODES_REPEATABILITY_AND_CAUSAL_BOUNDARY

FAILURE_CHARACTERIZATION_OBJECTIVE_SATISFIED=
YES

FAILURE_CHARACTERIZATION_CLOSURE_READINESS=
READY

CORRIDOR_CLOSURE=
NO

CORRIDOR_CLOSE_COMMIT_AUTHORIZED=
NO_PENDING_USER_DR

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
STOP_FOR_USER_DR_BEFORE_CLOSING_FAILURE_CHARACTERIZATION
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-failure-characterization-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Failure Characterization closure-readiness scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

git diff --check
