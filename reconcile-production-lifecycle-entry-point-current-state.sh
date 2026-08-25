#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE PRODUCTION LIFECYCLE ENTRY POINT CURRENT STATE ==="
echo "BASELINE_COMMIT=ee91560a"
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT ENTRY-POINT EVIDENCE ==="
for f in \
  server/lifecycle/production-lifecycle-entry-point.ts \
  server/lifecycle/production-lifecycle-entry-point.test.ts \
  docs/native-database-validation-strategy-finding.md \
  docs/native-runtime-validation-decision-corridor.md
do
  [[ -f "$f" ]] || continue
  echo "--- $f ---"
  rg -n \
    'production lifecycle entry point|native-free|revert|reverted|blocked|implementation|validation|NEXT_ACTION|Current Status|Planning remains valid' \
    "$f" 2>/dev/null || true
done

echo
echo "=== CURRENT REPOSITORY SEARCH ==="
rg -n \
  'createProductionLifecycleEntryPoint|productionLifecycleEntryPoint|production lifecycle entry point|PRODUCTION_LIFECYCLE_ENTRY_POINT' \
  server routes db docs scripts \
  -g '*.ts' -g '*.md' -g '*.sh' \
  2>/dev/null || true

echo
echo "=== RECONCILIATION BOUNDARY ==="
echo "HISTORICAL_REVERT_AUTOMATICALLY_MEANS_CURRENT_GAP=NO"
echo "NATIVE_DATABASE_BLOCKER_CURRENTLY_ESTABLISHED=NO"
echo "ENTRY_POINT_CURRENT_CAPABILITY_STATE=REQUIRES_REPOSITORY_EVIDENCE_CLASSIFICATION"
echo "SUCCESSOR_SELECTION_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_PRODUCTION_LIFECYCLE_ENTRY_POINT_AS_IMPLEMENTED_PARTIAL_ABSENT_OR_DEFERRED_ON_CURRENT_BASELINE"
