#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE STABILITY DETERMINATION CORRIDOR ==="

expected_head="5a4ce744"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches Stability Determination closure-readiness checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-stability-determination-corridor\.sh$|^ M scripts/close-stability-determination-corridor\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'STABILITY_DETERMINATION_CLOSURE_READINESS=' \
  scripts/classify-stability-determination-completeness.sh

grep -q 'READY' \
  scripts/classify-stability-determination-completeness.sh

grep -q 'UNQUALIFIED_PRODUCTION_STABILITY_NOT_ESTABLISHED' \
  scripts/classify-production-stability-from-established-evidence.sh

grep -q 'MATERIAL_GENERATION_INSTABILITY_ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE' \
  scripts/classify-production-stability-from-established-evidence.sh

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

STABILITY_DETERMINATION=
COMPLETE

STABILITY_DETERMINATION_DR=
20260812_010321

STABILITY_DETERMINATION_RESULT=
UNQUALIFIED_PRODUCTION_STABILITY_NOT_ESTABLISHED

MATERIAL_GENERATION_INSTABILITY=
ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE

FAIL_CLOSED_VALIDATION=
PRESERVED

VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED

DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED

FIXED_SEED_AS_PRODUCTION_REMEDY=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

STABILITY_DETERMINATION_CORRIDOR=
CLOSED

PHASE_CORRIDOR_COUNT=
4

PHASE_CORRIDORS_COMPLETE=
4_OF_4

PHASE_CLOSURE=
NOT_PERFORMED

MILESTONE_CLOSURE=
NOT_PERFORMED

NEXT_CORRIDOR=
NOT_ESTABLISHED

NEXT_ACTION=
STOP_FOR_USER_CONSULTATION_BEFORE_PHASE_OR_MILESTONE_DISPOSITION
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-stability-determination-corridor\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside Stability Determination closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
