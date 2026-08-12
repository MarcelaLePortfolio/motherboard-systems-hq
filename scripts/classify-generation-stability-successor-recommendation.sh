#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION STABILITY SUCCESSOR RECOMMENDATION ==="

expected_head="80dbb4b6"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches successor-options investigation checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-stability-successor-recommendation\.sh$|^ M scripts/classify-generation-stability-successor-recommendation\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'SUCCESSOR_OPTION_1=' \
  scripts/investigate-generation-stability-successor-options.sh
grep -q 'PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION' \
  scripts/investigate-generation-stability-successor-options.sh
grep -q 'SUCCESSOR_OPTION_2=' \
  scripts/investigate-generation-stability-successor-options.sh
grep -q 'NO_IMMEDIATE_SUCCESSOR_PHASE_AND_KEEP_INSTABILITY_AS_DEFERRED_KNOWN_CONDITION' \
  scripts/investigate-generation-stability-successor-options.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

MILESTONE_STATUS=
OPEN

CLOSED_PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

ESTABLISHED_REMAINING_CONDITION=
MATERIAL_GENERATION_INSTABILITY_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE

PRODUCTION_STABILITY=
NOT_ESTABLISHED

VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED

DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY_REMEDY=
NOT_ESTABLISHED

SUCCESSOR_OPTION_1=
PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION

SUCCESSOR_OPTION_2=
DEFER_GENERATION_INSTABILITY_AS_KNOWN_CONDITION

EVIDENCE_SUPPORTED_RECOMMENDATION=
SUCCESSOR_OPTION_1

RECOMMENDATION_BASIS=
The Generation Stability milestone remains open specifically because production
stability has not been established.

Characterization has already established material generation instability while
preserving the deterministic runtime and fail-closed validator boundaries.

The fixed-seed diagnostic established controlled repeatability, but production
policy suitability and wider semantic preservation remain unresolved.

Therefore the most direct evidence-supported continuation is a bounded
investigation of production generation policy and semantic preservation.

This recommendation does not authorize a production seed, temperature, top_p,
top_k, retry, model, validator, or other runtime change.

Option 2 remains valid if the user chooses to defer the known instability
instead of continuing the Generation Stability milestone now.

SUCCESSOR_PHASE=
NOT_SELECTED

SUCCESSOR_CORRIDOR=
NOT_SELECTED

RECOMMENDATION_ONLY=
YES

USER_DECISION_REQUIRED=
YES

SUCCESSOR_PHASE_OR_CORRIDOR_AUTHORIZED=
NO

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
STOP_FOR_USER_DECISION_ON_OPTION_1_OR_OPTION_2
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-stability-successor-recommendation\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside successor recommendation scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
