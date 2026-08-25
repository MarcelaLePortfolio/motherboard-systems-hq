#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY REMAINING CURRENT PROGRAM CAPABILITY GAPS ==="
echo "BASELINE_COMMIT=0c760be9"
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT GAP EVIDENCE ==="
for f in \
  scripts/classify-remaining-evidence-supported-capability-gap.sh \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh \
  scripts/reconcile-post-phase-3-broader-program-state-and-deferred-work.sh \
  docs/native-database-validation-strategy-finding.md
do
  if [[ -f "$f" ]]; then
    echo "--- $f ---"
    rg -n \
      'remaining gap|remaining capability|DEFERRED|UNRESOLVED|NOT_IMPLEMENTED|SUCCESSOR_MILESTONE|NEXT_MILESTONE|NEXT_ACTION|Native Database Validation Strategy|CROSS_TURN_TRANSITION_VALIDATION' \
      "$f" 2>/dev/null || true
  fi
done

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "CURRENT_GAPS_REQUIRE_EVIDENCE_RECONCILIATION=YES"
echo "HISTORICAL_DEFERRED_WORK_AUTOMATICALLY_CURRENT=NO"
echo "NATIVE_DATABASE_VALIDATION_STRATEGY_AUTOMATICALLY_CURRENT=NO"
echo "SUCCESSOR_SELECTION_FROM_HISTORICAL_LABELS_ALLOWED=NO"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=DETERMINE_WHICH_REMAINING_CAPABILITY_GAPS_ARE_STILL_CURRENT_ON_THE_POST_MISSION_CONTROL_BASELINE"
