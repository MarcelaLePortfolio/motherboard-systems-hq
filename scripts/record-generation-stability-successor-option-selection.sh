#!/usr/bin/env bash
set -euo pipefail

echo "=== RECORD GENERATION STABILITY SUCCESSOR OPTION SELECTION ==="

expected_head="c57b8b43"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches successor-recommendation checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/record-generation-stability-successor-option-selection\.sh$|^ M scripts/record-generation-stability-successor-option-selection\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'EVIDENCE_SUPPORTED_RECOMMENDATION=' \
  scripts/classify-generation-stability-successor-recommendation.sh

grep -q 'SUCCESSOR_OPTION_1' \
  scripts/classify-generation-stability-successor-recommendation.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

MILESTONE_STATUS=
OPEN

CLOSED_PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

USER_SUCCESSOR_DECISION=
CONTINUE_GENERATION_STABILITY_WORK

SELECTED_SUCCESSOR_OPTION=
PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION

SELECTION_STATUS=
USER_APPROVED

SUCCESSOR_DIRECTION=
ESTABLISHED

SUCCESSOR_PHASE=
PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION

SUCCESSOR_PHASE_STATUS=
SELECTED_NOT_STARTED

SUCCESSOR_CORRIDOR_MAP=
NOT_YET_ESTABLISHED

SUCCESSOR_CORRIDOR=
NOT_YET_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
INVESTIGATE_AND_CONSULT_ON_SUCCESSOR_PHASE_CORRIDOR_MAP_BEFORE_STARTING_PHASE

CORRIDOR_OR_PHASE_CLOSURE=
NO
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/record-generation-stability-successor-option-selection\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside successor-selection scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
