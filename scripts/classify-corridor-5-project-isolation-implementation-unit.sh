#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 5 · PROJECT ISOLATION BOUNDARY\n'
printf 'STATUS: 🟢 ACTIVE · IMPLEMENTATION UNIT CLASSIFICATION\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=PROJECT_ISOLATION_BOUNDARY' \
'CLASSIFICATION_DR=61adf6f5' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== CURRENT PROVIDER CONTRACT ===\n'
sed -n '1,220p' client/src/mission-control/MissionControlProvider.tsx

printf '\n=== CURRENT DASHBOARD MOUNT ===\n'
sed -n '1,110p' client/src/shell/WorkspaceMount.tsx

printf '\n=== CURRENT DASHBOARD LOAD ===\n'
grep -n -C 8 \
  -E 'ACTIVE_PACKAGE_ID|loadMission\\(|useMissionControl\\(' \
  client/src/shell/MissionDashboardWorkspace.tsx || true

printf '\n=== REFERENCE PROJECT-SCOPED PROVIDER ===\n'
sed -n '45,215p' client/src/packages/PackageReadProvider.tsx

printf '\n=== TEST SURFACE ===\n'
find client/src -type f \
  | grep -Ei 'mission-control.*test|MissionControlProvider.*test|MissionDashboard.*test|PackageReadProvider.*test' \
  | sort || true

grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'MissionControlProvider|loadMission\\(|MissionRead.*project|project mismatch|activeProjectId' \
  client/src \
  --include='*.test.ts' \
  --include='*.test.tsx' \
  2>/dev/null | head -420 || true

printf '\n=== MINIMUM UNIT CANDIDATES ===\n'
printf '%s\n' \
'CANDIDATE_A=Pass activeProjectId into MissionControlProvider and reset provider state when it changes.' \
'CANDIDATE_B=Additionally reject Mission Read results whose identity.project_id does not equal activeProjectId.' \
'CANDIDATE_C=Change Mission Read API/repository to accept projectId as an additional lookup key.' \
'CANDIDATE_D=Remove hard-coded ACTIVE_PACKAGE_ID or replace it with active mission discovery.'

printf '\n=== SCOPE TEST ===\n'
printf '%s\n' \
'CANDIDATE_A_REQUIRES_ACTIVE_PACKAGE_SELECTION=NO' \
'CANDIDATE_B_REQUIRES_ACTIVE_PACKAGE_SELECTION=NO' \
'CANDIDATE_C_REQUIRES_BACKEND_CONTRACT_CHANGE=YES' \
'CANDIDATE_D_REQUIRES_ACTIVE_PACKAGE_SELECTION=YES' \
'CANDIDATE_D_AUTHORIZED=NO'

printf '\n=== DECISION GATE ===\n'
printf '%s\n' \
'QUESTION_1=Is provider project binding plus reset sufficient to prevent stale cross-project state?' \
'QUESTION_2=Is client-side authoritative project_id mismatch rejection needed in the same unit to fail closed?' \
'QUESTION_3=Can both protections be validated without changing Package selection behavior?' \
'QUESTION_4=Can the backend Mission Read contract remain unchanged for this corridor?' \
'IF_A_PLUS_B_SUFFICIENT=MINIMUM_IMPLEMENTATION_UNIT=PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION' \
'IF_BACKEND_SCOPE_REQUIRED=STOP_AND_RECLASSIFY_BEFORE_IMPLEMENTATION' \
'ACTIVE_PACKAGE_SELECTION_AUTHORIZED=NO' \
'BACKEND_CONTRACT_CHANGE_AUTHORIZED=NO' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
