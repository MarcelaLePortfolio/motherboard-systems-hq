#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🔎 CORRIDOR 5 · ALTERNATIVE PROJECT ISOLATION CLASSIFICATION\n'
printf 'STATUS: INVESTIGATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=PROJECT_ISOLATION_BOUNDARY' \
'STABLE_BASE=c828acb8' \
'REVERT_COMMIT=93dbb947' \
'LIVE_UI_RESTORED_COMMIT=f99377b5' \
'FAILED_IMPLEMENTATION=1e2c8343' \
'FAILED_APPROACH=PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION_AS_IMPLEMENTED' \
'NEW_IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== CURRENT STABLE MISSION CONTROL SURFACES ===\n'
sed -n '1,240p' client/src/mission-control/MissionControlProvider.tsx
printf '\n--- MissionDashboardWorkspace.tsx ---\n'
sed -n '1,240p' client/src/shell/MissionDashboardWorkspace.tsx
printf '\n--- WorkspaceMount.tsx ---\n'
sed -n '1,220p' client/src/shell/WorkspaceMount.tsx

printf '\n=== ACTIVE PROJECT CONTEXT REFERENCES ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'activeProjectId|activeProject|useProjectContext|project_id' \
  client/src/project-context \
  client/src/shell \
  client/src/mission-control \
  client/src/packages \
  2>/dev/null || true

printf '\n=== EXISTING PROJECT-SCOPED PROVIDER PATTERNS ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'Provider.*projectId|projectId=.*Provider|useEffect.*project|key=.*project' \
  client/src \
  2>/dev/null || true

printf '\n=== MISSION READ CLIENT CONTRACT ===\n'
sed -n '1,240p' client/src/mission-control/missionReadApi.ts
printf '\n--- Mission Read route ---\n'
sed -n '1,260p' routes/api-mission-read.ts
printf '\n--- Mission Read repository ---\n'
sed -n '1,300p' db/mission-read-repository.ts

printf '\n=== PACKAGE READ PROJECT-ISOLATION REFERENCE ===\n'
find client/src/packages -maxdepth 2 -type f -print | sort
printf '\n'
grep -RIn \
  --exclude-dir=node_modules \
  -E 'projectId|project_id|activeProject|reset|mismatch|load' \
  client/src/packages \
  2>/dev/null || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
printf '%s\n' \
'Q1=Can project isolation be enforced at the Mission Read invocation boundary without provider mount/reset effects?' \
'Q2=Can stable Mission Control rendering remain unchanged while cross-project data is rejected?' \
'Q3=Is there an existing repository-consistent pattern in Package Read or another provider that should be reused?' \
'Q4=Can the alternative avoid changing ACTIVE_PACKAGE_ID or active-mission selection?' \
'Q5=Can the alternative avoid backend/repository changes?' \
'Q6=What is the smallest materially different implementation unit?' \
'Q7=What live-UI behavior must be explicitly validated before closure?'

printf '\n=== PROTECTED BOUNDARY ===\n'
printf '%s\n' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'ACTIVE_MISSION_SELECTION_AUTHORIZED=NO' \
'BACKEND_CHANGE_AUTHORIZED=NO' \
'ATLAS_CHANGE_AUTHORIZED=NO' \
'MISSION_CONTROL_MUST_REMAIN_READ_ONLY=YES' \
'FULL_MISSION_CONTROL_UI_MUST_REMAIN_RENDERING=YES' \
'FAILED_APPROACH_MUST_NOT_BE_REPEATED=YES'
