#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE REMAINING PROGRAM PRIORITY ==="
echo "BASELINE_COMMIT=3660e586"
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "NATIVE_DATABASE_VALIDATION_STRATEGY_CURRENT_GAP=NO"
echo "PRODUCTION_LIFECYCLE_ENTRY_POINT_CURRENT_GAP=NO"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== REMAINING PROGRAM EVIDENCE ==="
for f in \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh \
  scripts/classify-remaining-evidence-supported-capability-gap.sh \
  scripts/reconcile-post-phase-3-broader-program-state-and-deferred-work.sh \
  scripts/reconcile-post-semantic-history-program-state-and-true-successor.sh
do
  [[ -f "$f" ]] || continue
  echo "--- $f ---"
  rg -n \
    'UNRESOLVED_CAPABILITY_GAP|REMAINING_DEFERRED|SEPARATELY_DEFERRED|DEFERRED_KNOWN_CONDITION|SUCCESSOR_MILESTONE|NEXT_MILESTONE|NEXT_ACTION|CURRENT.*CAPABILITY|PROGRAM_PRIORITY' \
    "$f" 2>/dev/null || true
done

echo
echo "=== CURRENT CAPABILITY SEARCH ==="
rg -n \
  'not yet implemented|NOT_IMPLEMENTED|remaining capability|remaining gap|unresolved capability|separately deferred|deferred known condition' \
  docs server db routes client/src \
  -g '*.md' -g '*.ts' -g '*.tsx' \
  2>/dev/null || true

echo
echo "=== RECONCILIATION BOUNDARY ==="
echo "HISTORICAL_DEFERRED_ITEM_AUTOMATICALLY_NEXT=NO"
echo "CURRENT_SUCCESSOR_REQUIRES_PRESENT_CAPABILITY_EVIDENCE=YES"
echo "SUCCESSOR_SELECTION_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_WHETHER_ANY_CURRENT_EVIDENCE_SUPPORTED_PROGRAM_CAPABILITY_GAP_REMAINS"
