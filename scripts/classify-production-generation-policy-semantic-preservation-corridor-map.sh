#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PRODUCTION GENERATION POLICY AND SEMANTIC PRESERVATION CORRIDOR MAP ==="

expected_head="961df120"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches reconciled successor-selection checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-production-generation-policy-semantic-preservation-corridor-map\.sh$|^ M scripts/classify-production-generation-policy-semantic-preservation-corridor-map\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'SELECTION_STATUS=' \
  scripts/record-generation-stability-successor-option-selection.sh
grep -q 'USER_APPROVED' \
  scripts/record-generation-stability-successor-option-selection.sh
grep -q 'PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION' \
  scripts/record-generation-stability-successor-option-selection.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

SUCCESSOR_PHASE=
PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION

SUCCESSOR_PHASE_STATUS=
SELECTED_NOT_STARTED

CORRIDOR_MAP_STATUS=
PROPOSED_FOR_USER_CONSULTATION

CORRIDOR_1=
GENERATION_POLICY_BOUNDARY

CORRIDOR_1_OBJECTIVE=
CLASSIFY_WHICH_GENERATION_CONTROLS_MAY_BE_CONSIDERED_WITHOUT_TREATING_DIAGNOSTIC_CONTROLS_AS_PRODUCTION_POLICY

CORRIDOR_2=
SEMANTIC_PRESERVATION

CORRIDOR_2_OBJECTIVE=
DETERMINE_WHETHER_CANDIDATE_GENERATION_CONTROLS_PRESERVE_REQUIRED_SEMANTIC_BEHAVIOR_ACROSS_BOUNDED_VALIDATION_SURFACES

CORRIDOR_3=
POLICY_SELECTION

CORRIDOR_3_OBJECTIVE=
DETERMINE_WHETHER_ANY_EVIDENCE_SUPPORTED_PRODUCTION_GENERATION_POLICY_CAN_BE_SELECTED_WITH_EXPLICIT_ROLLBACK_BOUNDARIES

CORRIDOR_4=
PRODUCTION_READINESS

CORRIDOR_4_OBJECTIVE=
CLASSIFY_WHETHER_THE_SELECTED_OR_REJECTED_POLICY_STATE_SUPPORTS_PRODUCTION_STABILITY_VALIDATION

CORRIDOR_COUNT=
4

CORRIDOR_MAP=
NOT_YET_USER_APPROVED

PHASE_STARTED=
NO

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
STOP_FOR_USER_CONSULTATION_ON_PROPOSED_FOUR_CORRIDOR_MAP
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-production-generation-policy-semantic-preservation-corridor-map\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside successor corridor-map classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
