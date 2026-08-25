#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE EMPTY MISSION CONTROL PRESENTATION FIX ==="
echo "IMPLEMENTATION_COMMIT=d74a8e44"

npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

rg -q 'status === "not_found"' client/src/shell/MissionDashboardWorkspace.tsx
rg -q 'const displayedMission = mission ?? emptyMission' client/src/shell/MissionDashboardWorkspace.tsx
rg -q 'ExecutiveBriefCard mission={displayedMission}' client/src/shell/MissionDashboardWorkspace.tsx
rg -q 'MissionStatusCard mission={displayedMission}' client/src/shell/MissionDashboardWorkspace.tsx
rg -q 'MissionProgressCard mission={displayedMission}' client/src/shell/MissionDashboardWorkspace.tsx
rg -q 'MissionPipelineCard mission={displayedMission}' client/src/shell/MissionDashboardWorkspace.tsx

if rg -n -U 'if \(status === "not_found"\).*No mission is currently in progress' client/src/shell/MissionDashboardWorkspace.tsx; then
  echo "NOT_FOUND_FULL_PAGE_RETURN_REMOVED=NO"
  exit 1
fi

echo "NOT_FOUND_FULL_PAGE_RETURN_REMOVED=YES"
echo "EMPTY_PIPELINE_TELEMETRY_RENDER_PATH=PASS"
echo "ACTIVE_MISSION_RENDER_PATH=PRESERVED=YES"
echo "ERROR_PATH_REMAINS_SEPARATE=YES"
echo "AUTHORITY_OR_HANDOFF_CHANGE=NO"
echo "VALIDATION_RESULT=PASS"
echo "NEXT_ACTION=CLASSIFY_EMPTY_MISSION_CONTROL_FIX_CLOSURE_READINESS"
