#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== REVERT CORRIDOR 5 RUNTIME TO LAST KNOWN STABLE MISSION CONTROL ==="
echo "STABLE_RUNTIME_BASE=c828acb8"
echo "FAILED_IMPLEMENTATION=1e2c8343"
echo "REASON=FULL_MISSION_CONTROL_UI_STOPPED_RENDERING"
echo "ACTION=RESTORE_ONLY_RUNTIME_FILES_CHANGED_BY_CORRIDOR_5"

git restore --source=c828acb8 -- \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/shell/WorkspaceMount.tsx

echo
echo "=== RESTORED DIFF ==="
git diff -- \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/shell/WorkspaceMount.tsx

echo
echo "=== BOUNDARY ==="
echo "CORRIDOR_5_IMPLEMENTATION_REVERTED=YES"
echo "LAST_KNOWN_STABLE_MISSION_CONTROL_RUNTIME_RESTORED=YES"
echo "ACTIVE_MISSION_SELECTION_CHANGE=NO"
echo "BACKEND_CHANGE=NO"
echo "ATLAS_CHANGE=NO"
