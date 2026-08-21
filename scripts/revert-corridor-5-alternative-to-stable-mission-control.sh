#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== ↩️ CORRIDOR 5 · ALTERNATIVE IMPLEMENTATION REVERT ==="
echo "STABLE_RUNTIME_BASE=c828acb8"
echo "FAILED_ALTERNATIVE_IMPLEMENTATION=5f40dc7c"
echo "LIVE_REGRESSION=PROJECT_MISMATCH_CARD_REPLACED_FULL_DASHBOARD"
echo "ACTION=RESTORE_STABLE_MISSION_CONTROL_RUNTIME"

git restore --source=c828acb8 -- \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== VERIFY RESTORED RUNTIME ===\n'
git diff --exit-code c828acb8 -- \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '%s\n' \
'STABLE_MISSION_CONTROL_RUNTIME_RESTORED=YES' \
'FAILED_ALTERNATIVE_REVERTED=YES' \
'ACTIVE_PACKAGE_SELECTION_CHANGE=NO' \
'BACKEND_CHANGE=NO' \
'GOVERNANCE_CHANGE=NO' \
'ATLAS_CHANGE=NO' \
'NEW_IMPLEMENTATION_AUTHORIZED=NO'
