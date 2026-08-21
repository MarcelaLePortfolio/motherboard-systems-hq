#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '✅ CORRIDOR 5 · PROJECT ISOLATION IMPLEMENTATION VALIDATION\n'
printf 'STATUS: VALIDATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=PROJECT_ISOLATION_BOUNDARY' \
'IMPLEMENTATION_COMMIT=1e2c8343' \
'ROLLBACK_DR=20260820_221628' \
'IMPLEMENTATION_UNIT=PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION' \
'ADDITIONAL_IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== IMPLEMENTATION FILE SCOPE ===\n'
git diff --name-only c828acb8..1e2c8343

printf '\n=== AUTHORIZED-SCOPE ASSERTIONS ===\n'

grep -Fq 'projectId: string | null;' \
  client/src/mission-control/MissionControlProvider.tsx

grep -Fq 'projectId={activeProjectId}' \
  client/src/shell/WorkspaceMount.tsx

grep -Fq 'requestSequenceRef.current += 1;' \
  client/src/mission-control/MissionControlProvider.tsx

grep -Fq 'setMission(null);' \
  client/src/mission-control/MissionControlProvider.tsx

grep -Fq 'setLastPackageId(null);' \
  client/src/mission-control/MissionControlProvider.tsx

grep -Fq 'readModel.identity.project_id !== normalizedProjectId' \
  client/src/mission-control/MissionControlProvider.tsx

grep -Fq 'does not belong to the active project' \
  client/src/mission-control/MissionControlProvider.tsx

printf '%s\n' \
'PROVIDER_PROJECT_BINDING_PRESENT=YES' \
'PROJECT_CHANGE_RESET_PRESENT=YES' \
'IN_FLIGHT_REQUEST_INVALIDATION_PRESENT=YES' \
'PROJECT_MISMATCH_FAIL_CLOSED_PRESENT=YES'

printf '\n=== PROHIBITED-SCOPE ASSERTIONS ===\n'

if git diff c828acb8..1e2c8343 --name-only | grep -Eq \
  '^(db/mission-read-repository\.ts|routes/api-mission-read\.ts)$'
then
  echo 'BACKEND_MISSION_READ_CONTRACT_CHANGED=YES'
  exit 1
else
  echo 'BACKEND_MISSION_READ_CONTRACT_CHANGED=NO'
fi

if git diff c828acb8..1e2c8343 -- \
  client/src/shell/MissionDashboardWorkspace.tsx \
  | grep -Eq '^[+-].*ACTIVE_PACKAGE_ID'
then
  echo 'ACTIVE_PACKAGE_SELECTION_BEHAVIOR_CHANGED=YES'
  exit 1
else
  echo 'ACTIVE_PACKAGE_SELECTION_BEHAVIOR_CHANGED=NO'
fi

printf '\n=== TYPE / BUILD VALIDATION ===\n'
if node -e '
  const p=require("./package.json");
  process.exit(p.scripts?.typecheck ? 0 : 1)
'; then
  pnpm typecheck
elif node -e '
  const p=require("./package.json");
  process.exit(p.scripts?.check ? 0 : 1)
'; then
  pnpm check
else
  pnpm exec tsc --noEmit
fi

printf '\n=== VALIDATION DISPOSITION ===\n'
printf '%s\n' \
'AUTHORIZED_IMPLEMENTATION_UNIT_PRESENT=YES' \
'PROVIDER_PROJECT_BINDING=PASS' \
'PROJECT_CHANGE_STATE_RESET=PASS' \
'PROJECT_MISMATCH_FAIL_CLOSED=PASS' \
'BACKEND_CONTRACT_CHANGE=NO' \
'ACTIVE_PACKAGE_SELECTION_CHANGE=NO' \
'MISSION_CONTROL_READ_ONLY_BOUNDARY=PRESERVED' \
'CORRIDOR_5_CLOSURE_READY=YES' \
'PRODUCTION_CHANGE=AUTHORIZED_BOUNDED_IMPLEMENTATION_ONLY'
