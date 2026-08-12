#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY REMAINING EVIDENCE-SUPPORTED CAPABILITY GAP ==="

expected_head="5ba0fefb"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches corrected reassessment checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-remaining-evidence-supported-capability-gap\.sh$|^ M scripts/classify-remaining-evidence-supported-capability-gap\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== VERIFY CORRECTED BASELINE ==="

grep -q 'ALREADY_IMPLEMENTED_AND_VALIDATED' \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh

grep -q 'DO_NOT_PROMOTE_WITHOUT_NEW_EVIDENCE' \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh

grep -q 'DO_NOT_CLASSIFY_AS_MISSING_RUNTIME_CAPABILITIES' \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh

echo "CORRECTED_BASELINE=CONFIRMED"

echo
echo "=== INSPECT PRIOR GAP CLAIMS ==="

grep -nE \
  'UNRESOLVED_CAPABILITY_GAP|PRIMARY_UNRESOLVED_CAPABILITY_GAP|CROSS_TURN|ranking|token|history window|hybrid|model runtime|optimization|unsurfaced|recovery|correlation|prompt' \
  scripts/classify-unresolved-capability-gaps.sh \
  scripts/classify-successor-priority-boundary.sh \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh \
  2>/dev/null | head -260

cat <<'MAP'
CLASSIFICATION_SCOPE=
REMAINING_CAPABILITY_GAPS_AFTER_CORRECTED_REPOSITORY_RECONCILIATION

PREVIOUS_PRIMARY_GAP=
CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION

PREVIOUS_PRIMARY_GAP_CURRENT_STATE=
ALREADY_IMPLEMENTED_AND_VALIDATED

REMAINING_DEFERRED_OPTIMIZATION_ITEMS=
REQUIREMENT_NOT_ESTABLISHED

KNOWN_PRODUCTION_GENERATION_INSTABILITY=
DEFERRED_KNOWN_CONDITION_NOT_NEW_CAPABILITY_GAP

IMPLEMENTED_BUT_UNSURFACED_ITEMS=
NOT_MISSING_RUNTIME_CAPABILITIES

RECOVERY_CORRELATION_REFINEMENTS=
DEFERRED_REFINEMENTS_NOT_ESTABLISHED_AS_REQUIRED_SUCCESSOR_CAPABILITY

PROMPT_EVOLUTION=
DEFERRED_NOT_ESTABLISHED_AS_REQUIRED_SUCCESSOR_CAPABILITY

REMAINING_EVIDENCE_SUPPORTED_CAPABILITY_GAP=
NONE_ESTABLISHED

UNRESOLVED_CAPABILITY_GAP_COUNT=
ZERO

SUCCESSOR_CAPABILITY=
NOT_ESTABLISHED

SUCCESSOR_MILESTONE=
NOT_ESTABLISHED

IMPLEMENTATION_READINESS=
NOT_APPLICABLE

IMPLEMENTATION_AUTHORIZED=
NO_NEW_IMPLEMENTATION_SCOPE_EXISTS

PRODUCTION_CHANGE=
NONE

PROGRAM_RECONCILIATION_DISPOSITION=
NO_REMAINING_EVIDENCE_SUPPORTED_CAPABILITY_GAP_ESTABLISHED

NEXT_ACTION=
CLASSIFY_PROGRAM_RECONCILIATION_MILESTONE_CLOSURE
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-remaining-evidence-supported-capability-gap\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
