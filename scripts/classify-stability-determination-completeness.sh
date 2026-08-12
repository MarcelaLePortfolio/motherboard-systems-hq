#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY STABILITY DETERMINATION COMPLETENESS ==="

expected_head="fb2f2519"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches Stability Determination checkpoint $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-stability-determination-completeness\.sh$|^ M scripts/classify-stability-determination-completeness\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'UNQUALIFIED_PRODUCTION_STABILITY_NOT_ESTABLISHED' \
  scripts/classify-production-stability-from-established-evidence.sh

grep -q 'MATERIAL_GENERATION_INSTABILITY_ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE' \
  scripts/classify-production-stability-from-established-evidence.sh

grep -q 'VALIDATOR_MALFUNCTION=' \
  scripts/classify-production-stability-from-established-evidence.sh

grep -q 'DETERMINISTIC_RUNTIME_REGRESSION=' \
  scripts/classify-production-stability-from-established-evidence.sh

grep -q 'FIXED_SEED_AS_PRODUCTION_REMEDY=' \
  scripts/classify-production-stability-from-established-evidence.sh

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED

CURRENT_CORRIDOR=
STABILITY_DETERMINATION

GENERATION_VARIANCE=
COMPLETE

FAILURE_CHARACTERIZATION=
COMPLETE

DIAGNOSTIC_CONTROLS=
COMPLETE

STABILITY_DETERMINATION=
ACTIVE

STABILITY_DETERMINATION_OBJECTIVE=
DETERMINE_WHETHER_UNQUALIFIED_PRODUCTION_STABILITY_IS_ESTABLISHED_ON_THE_TESTED_PRODUCTION_EQUIVALENT_SURFACE

PRODUCTION_STABILITY=
NOT_ESTABLISHED

MATERIAL_GENERATION_INSTABILITY=
ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE

VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED

DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED

FIXED_SEED_AS_PRODUCTION_REMEDY=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

STABILITY_DETERMINATION_OBJECTIVE_SATISFIED=
YES

STABILITY_DETERMINATION_CLOSURE_READINESS=
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
STOP_FOR_USER_DR_BEFORE_CLOSING_STABILITY_DETERMINATION
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-stability-determination-completeness\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside Stability Determination completeness scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
