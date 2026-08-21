#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 5 · PROJECT ISOLATION BOUNDARY\n'
printf 'STATUS: 🟢 NOW ACTIVE · CLASSIFICATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR_1=AUTHORITATIVE_ACTIVE_MISSION_SELECTION:CLOSED_DR_PROTECTED' \
'CORRIDOR_2=CANONICAL_TO_GOVERNANCE_PACKAGE_TRANSITION:CLOSED_DR_PROTECTED' \
'CORRIDOR_3=AUTHORITATIVE_PACKAGE_LINEAGE_RECONCILIATION:CLOSED_DR_PROTECTED' \
'CORRIDOR_4=DOWNSTREAM_OPERATIONAL_STATE_BOUNDARY:CLOSED_DR_PROTECTED' \
'CORRIDOR_5=PROJECT_ISOLATION_BOUNDARY' \
'ACTIVE_MISSION_SELECTION_REMAINS_BLOCKED=YES' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== WHY CORRIDOR 5 EXISTS ===\n'
printf '%s\n' \
'FINDING=Mission Control still hard-codes package identity corridor-smoke.' \
'FINDING=Project-scoped identity already exists in Mission Read output.' \
'FINDING=Active project context exists elsewhere in the client runtime.' \
'QUESTION=Can Mission Control state be safely isolated by active project without selecting an active mission?'

printf '\n=== MISSION CONTROL PROVIDER ===\n'
sed -n '1,240p' client/src/mission-control/MissionControlProvider.tsx

printf '\n=== MISSION DASHBOARD LOAD BOUNDARY ===\n'
sed -n '1,430p' client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== MISSION READ CLIENT ===\n'
sed -n '1,220p' client/src/mission-control/missionReadApi.ts

printf '\n=== MISSION READ ROUTE ===\n'
sed -n '1,240p' routes/api-mission-read.ts

printf '\n=== MISSION READ REPOSITORY ===\n'
sed -n '1,240p' db/mission-read-repository.ts

printf '\n=== ACTIVE PROJECT PROPAGATION ===\n'
sed -n '1,130p' client/src/shell/WorkspaceMount.tsx

printf '\n--- PACKAGE READ PROVIDER REFERENCE MODEL ---\n'
sed -n '1,230p' client/src/packages/PackageReadProvider.tsx

printf '\n=== PROJECT ID MATCH / REJECTION SEARCH ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'project_id.*projectId|projectId.*project_id|project mismatch|wrong project|activeProjectId.*Mission|Mission.*activeProjectId|re-key|rekey|lastPackageId' \
  client/src/mission-control \
  client/src/shell \
  routes/api-mission-read.ts \
  db/mission-read-repository.ts \
  2>/dev/null | head -420 || true

printf '\n=== CORRIDOR 5 DECISION GATE ===\n'
printf '%s\n' \
'QUESTION_1=Does MissionControlProvider currently retain mission state across active-project changes?' \
'QUESTION_2=Can project switching clear or re-key Mission Control state without choosing a package?' \
'QUESTION_3=Can a loaded Mission Read result be rejected when its project_id does not match the active project?' \
'QUESTION_4=Would those protections preserve the existing prohibition against inferring active mission identity?' \
'IF_PROJECT_ISOLATION_CAN_BE_ADDED_WITHOUT_PACKAGE_SELECTION=SAFE_BOUNDED_CORRIDOR_EXISTS' \
'IF_PROJECT_ISOLATION_REQUIRES_ACTIVE_PACKAGE_INFERENCE=BLOCKED_WITH_PHASE_DEPENDENCY' \
'ACTIVE_PACKAGE_SELECTION_AUTHORIZED=NO' \
'MISSION_CONTROL_OPERATIONAL_INFERENCE_AUTHORIZED=NO' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
