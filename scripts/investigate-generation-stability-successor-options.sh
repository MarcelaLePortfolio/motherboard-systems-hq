#!/usr/bin/env bash
set -euo pipefail

echo "=== INVESTIGATE GENERATION STABILITY SUCCESSOR OPTIONS ==="

expected_head="b123ebd6"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches consultation DR checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-generation-stability-successor-options\.sh$|^ M scripts/investigate-generation-stability-successor-options\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'CONSULTATION_GATE=' \
  scripts/record-generation-stability-consultation-gate.sh
grep -q 'ACTIVE' \
  scripts/record-generation-stability-consultation-gate.sh
grep -q '20260812_011426' \
  scripts/record-generation-stability-consultation-dr-checkpoint.sh

echo "=== INSPECT ESTABLISHED REMAINING CONDITION ==="

grep -nE \
  'PRODUCTION_STABILITY=|MATERIAL_GENERATION_INSTABILITY=|PRODUCTION_GENERATION_POLICY_REMEDY=|FIXED_SEED_AS_PRODUCTION_REMEDY=|VALIDATOR_MALFUNCTION=|DETERMINISTIC_RUNTIME_REGRESSION=' \
  scripts/close-production-generation-stability-characterization-phase.sh \
  scripts/classify-production-stability-from-established-evidence.sh \
  scripts/record-generation-stability-consultation-gate.sh

echo
echo "=== INSPECT EXISTING POLICY / CONTROL INVESTIGATION SURFACES ==="

find scripts -maxdepth 1 -type f \
  \( -iname '*generation*policy*' \
     -o -iname '*fixed*seed*' \
     -o -iname '*semantic*preservation*' \
     -o -iname '*production*stability*' \) \
  -print | sort

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

MILESTONE_STATUS=
OPEN

CLOSED_PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CONSULTATION_GATE=
ACTIVE

CONSULTATION_DR=
20260812_011426

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

SUCCESSOR_INVESTIGATION_SCOPE=
DETERMINE_WHETHER_THE_REMAINING_GENERATION_INSTABILITY_SUPPORTS_A_BOUNDED_SUCCESSOR_PHASE

SUCCESSOR_OPTION_1=
PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION

SUCCESSOR_OPTION_1_BASIS=
FIXED_SEED_DIAGNOSTIC_ESTABLISHED_CONTROLLED_REPEATABILITY_BUT_PRODUCTION_POLICY_AND_SEMANTIC_PRESERVATION_REMAIN_UNESTABLISHED

SUCCESSOR_OPTION_2=
NO_IMMEDIATE_SUCCESSOR_PHASE_AND_KEEP_INSTABILITY_AS_DEFERRED_KNOWN_CONDITION

SUCCESSOR_OPTION_2_BASIS=
NO_PRODUCTION_RUNTIME_REGRESSION_OR_VALIDATOR_MALFUNCTION_HAS_BEEN_ESTABLISHED_AND_NO_REMEDY_IS_CURRENTLY_AUTHORIZED

SUCCESSOR_PHASE=
NOT_SELECTED

SUCCESSOR_CORRIDOR=
NOT_SELECTED

SUCCESSOR_PHASE_OR_CORRIDOR_AUTHORIZED=
NO

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

INVESTIGATION_ONLY=
YES

NEXT_ACTION=
CONSULT_WITH_USER_ON_SUCCESSOR_OPTION_1_VERSUS_SUCCESSOR_OPTION_2
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-generation-stability-successor-options\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside successor-option investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
