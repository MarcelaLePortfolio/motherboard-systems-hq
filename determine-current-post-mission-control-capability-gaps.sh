#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DETERMINE CURRENT POST-MISSION-CONTROL CAPABILITY GAPS ==="
echo "BASELINE_COMMIT=609fd4f9"
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== RECONCILE HISTORICAL GAP CLASSIFICATIONS ==="
for f in \
  scripts/classify-remaining-evidence-supported-capability-gap.sh \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh \
  scripts/reconcile-post-phase-3-broader-program-state-and-deferred-work.sh \
  docs/native-database-validation-strategy-finding.md
do
  [[ -f "$f" ]] || continue
  echo "--- $f ---"
  sed -n '1,140p' "$f" | rg \
    'UNRESOLVED_CAPABILITY_GAP_COUNT=|SUCCESSOR_MILESTONE=|CROSS_TURN_TRANSITION_VALIDATION=|REMAINING_DEFERRED|DEFERRED_KNOWN_CONDITION|NEXT_ACTION=|next canonical milestone|Native Database Validation Strategy|SEPARATELY_DEFERRED' \
    || true
done

echo
echo "=== CURRENT BASELINE SEARCH ==="
rg -n \
  'CROSS_TURN_TRANSITION_VALIDATION|Native Database Validation Strategy|native database validation|UNRESOLVED_CAPABILITY_GAP|NOT_IMPLEMENTED|SEPARATELY_DEFERRED' \
  db server routes client/src docs \
  -g '*.ts' -g '*.tsx' -g '*.md' \
  2>/dev/null || true

echo
echo "=== DETERMINATION BOUNDARY ==="
echo "HISTORICAL_LABEL_ALONE_ESTABLISHES_CURRENT_GAP=NO"
echo "CURRENT_REPOSITORY_EVIDENCE_REQUIRED=YES"
echo "SUCCESSOR_SELECTION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_EACH_CANDIDATE_AS_CURRENT_GAP_COMPLETED_DEFERRED_OR_NON_CAPABILITY_CONDITION"
