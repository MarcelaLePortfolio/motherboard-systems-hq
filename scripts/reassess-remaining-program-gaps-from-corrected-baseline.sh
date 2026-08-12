#!/usr/bin/env bash
set -euo pipefail

echo "=== REASSESS REMAINING PROGRAM GAPS FROM CORRECTED BASELINE ==="

expected_head="eefe5f25"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches corrected successor-state checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reassess-remaining-program-gaps-from-corrected-baseline\.sh$|^ M scripts/reassess-remaining-program-gaps-from-corrected-baseline\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CORRECTED BASELINE ==="
grep -nE \
  'CROSS_TURN_TRANSITION_VALIDATION=|ALREADY_IMPLEMENTED_AND_VALIDATED|PRIOR_UNRESOLVED_CAPABILITY_GAP=|SUCCESSOR_MILESTONE=|NEXT_ACTION=' \
  scripts/reconcile-successor-capability-and-program-priority-state.sh

echo
echo "=== DEFERRED WORK EVIDENCE ==="
grep -nE \
  'production generation instability|semantic history ranking|token budget|history window|hybrid context|model runtime|integrated optimization|evaluatedInterpretations|contaminationEvaluations|recovery/correlation|prompt evolution|20-turn' \
  scripts/classify-deferred-work-inventory.sh \
  scripts/*deferred*work*.sh \
  scripts/*semantic*history*.sh \
  2>/dev/null | head -240 || true

echo
echo "=== REMAINING CAPABILITY-GAP CLASSIFICATION SURFACES ==="
find scripts -maxdepth 1 -type f \
  \( -iname '*capability*gap*' -o -iname '*successor*priority*' -o -iname '*program*reconciliation*' \) \
  -print | sort

cat <<'MAP'
REASSESSMENT_SCOPE=
REMAINING_DEFERRED_AND_UNRESOLVED_PROGRAM_WORK_AFTER_CORRECTED_CAPABILITY_BASELINE
CROSS_TURN_TRANSITION_VALIDATION=
ALREADY_IMPLEMENTED_AND_VALIDATED
KNOWN_PRODUCTION_GENERATION_INSTABILITY=
DEFERRED_KNOWN_CONDITION
REQUIREMENT_UNESTABLISHED_OPTIMIZATION_ITEMS=
DO_NOT_PROMOTE_WITHOUT_NEW_EVIDENCE
IMPLEMENTED_BUT_UNSURFACED_ITEMS=
DO_NOT_CLASSIFY_AS_MISSING_RUNTIME_CAPABILITIES
NEW_SUCCESSOR_CAPABILITY=
NOT_YET_ESTABLISHED
IMPLEMENTATION_AUTHORIZATION=
NOT_APPLICABLE_UNTIL_NEW_REQUIREMENT_IS_ESTABLISHED
PRODUCTION_CHANGE=
NONE
NEXT_ACTION=
CLASSIFY_WHETHER_ANY_REMAINING_EVIDENCE_SUPPORTED_CAPABILITY_GAP_EXISTS
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reassess-remaining-program-gaps-from-corrected-baseline\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside reassessment scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
