#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY EXISTING DIAGNOSTIC CONTROLS AND BOUNDARIES ==="

echo "=== VERIFY CORRIDOR BASELINE ==="
grep -q 'FAILURE_CHARACTERIZATION_CORRIDOR=' \
  scripts/close-failure-characterization-corridor.sh
grep -q 'CLOSED' \
  scripts/close-failure-characterization-corridor.sh
echo "FAILURE_CHARACTERIZATION_CLOSURE=CONFIRMED"

echo "=== VERIFY DIAGNOSTIC CONTROL EVIDENCE ==="
grep -q 'FIXED_SEED=424242' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh
grep -q 'PRODUCTION_WORKFLOW=UNCHANGED' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh
grep -q 'PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh
grep -q 'EXACT_REPEATABILITY=CONFIRMED' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh
echo "FIXED_SEED_DIAGNOSTIC_CONTROL=CONFIRMED"

echo "=== VERIFY PRODUCTION CONTROL BOUNDARY ==="
grep -q 'NO_EXPLICIT_SEED' \
  scripts/classify-generation-policy-configuration-and-rollback-boundary.sh
grep -q 'NO_EXPLICIT_TEMPERATURE' \
  scripts/classify-generation-policy-configuration-and-rollback-boundary.sh
grep -q 'NO_EXPLICIT_TOP_P' \
  scripts/classify-generation-policy-configuration-and-rollback-boundary.sh
grep -q 'NO_EXPLICIT_TOP_K' \
  scripts/classify-generation-policy-configuration-and-rollback-boundary.sh
echo "PRODUCTION_CONTROL_BOUNDARY=CONFIRMED"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED
CORRIDOR=
DIAGNOSTIC_CONTROLS

GENERATION_VARIANCE=
COMPLETE
FAILURE_CHARACTERIZATION=
COMPLETE
DIAGNOSTIC_CONTROLS=
ACTIVE
STABILITY_DETERMINATION=
PENDING

EXISTING_DIAGNOSTIC_CONTROL=
REQUEST_SCOPED_VALIDATION_ONLY_FIXED_SEED

FIXED_SEED=
424242

FIXED_SEED_CAPABILITY=
EXACT_REPEATABILITY_FOR_BOUNDED_IDENTICAL_DIAGNOSTIC_GENERATION

FIXED_SEED_DIAGNOSTIC_VALUE=
CAN_COMPARE_CONTROLLED_REPEATABLE_GENERATION_AGAINST_ORDINARY_UNSEEDED_VARIANCE

FIXED_SEED_DOES_ESTABLISH=
GENERATION_BEHAVIOR_IS_SENSITIVE_TO_GENERATION_CONTROL_STATE
EXACT_REPEATABILITY_CAN_BE_OBTAINED_ON_THE_BOUNDED_DIAGNOSTIC_SURFACE

FIXED_SEED_DOES_NOT_ESTABLISH=
ROOT_CAUSE_OF_ALL_SEMANTIC_FAILURES
PRODUCTION_STABILITY
PRODUCTION_SEMANTIC_SAFETY
ACCEPTABLE_PRODUCTION_GENERATION_POLICY
FIXED_SEED_AS_PRODUCTION_REMEDY

PRODUCTION_WORKFLOW_SEED=
ABSENT

PRODUCTION_TEMPERATURE=
NOT_EXPLICITLY_CONTROLLED

PRODUCTION_TOP_P=
NOT_EXPLICITLY_CONTROLLED

PRODUCTION_TOP_K=
NOT_EXPLICITLY_CONTROLLED

TEMPERATURE_DIAGNOSTIC_EVIDENCE=
NOT_ESTABLISHED

TOP_P_DIAGNOSTIC_EVIDENCE=
NOT_ESTABLISHED

TOP_K_DIAGNOSTIC_EVIDENCE=
NOT_ESTABLISHED

ADDITIONAL_GENERATION_CONTROL_EXPERIMENTS=
NOT_AUTHORIZED_BY_THIS_CLASSIFICATION

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

DIAGNOSTIC_CONTROL_BOUNDARY_CLASSIFICATION=
A bounded request-scoped fixed-seed control already exists and has demonstrated
exact repeatability on the established diagnostic surface.

That control is sufficient to distinguish ordinary unseeded output variance
from a controlled repeatable generation condition.

Repository evidence does not establish equivalent diagnostic findings for
temperature, top_p, or top_k, and those controls must not be introduced merely
to expand the diagnostic surface without a separately established need.

The existing fixed-seed diagnostic must remain validation-only and must not be
interpreted as production policy, production remediation, or proof of production
stability.

CORRIDOR_CLOSURE=
NO

DIAGNOSTIC_CONTROLS_CORRIDOR=
ACTIVE

NEXT_ACTION=
DETERMINE_DIAGNOSTIC_CONTROLS_COMPLETENESS
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-existing-diagnostic-controls-and-boundaries.sh$' ||
  true
)"
if [[ -n "$changed" ]]; then
  echo "STOP: files outside Diagnostic Controls classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo
echo "=== DIFF CHECK ==="
git diff --check
