#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 PHASE DECISION · CORRIDOR 5 OR PHASE CLOSURE\n'
printf 'STATUS: 🟢 ACTIVE · CLASSIFICATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR_1=AUTHORITATIVE_ACTIVE_MISSION_SELECTION:CLOSED_DR_PROTECTED' \
'CORRIDOR_2=CANONICAL_TO_GOVERNANCE_PACKAGE_TRANSITION:CLOSED_DR_PROTECTED' \
'CORRIDOR_3=AUTHORITATIVE_PACKAGE_LINEAGE_RECONCILIATION:CLOSED_DR_PROTECTED' \
'CORRIDOR_4=DOWNSTREAM_OPERATIONAL_STATE_BOUNDARY:CLOSED_DR_PROTECTED' \
'UPSTREAM_GOVERNANCE_RUNTIME_ACTIVATION_DEPENDENCY=YES' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== PHASE-SCOPE EVIDENCE ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'Project-Scoped Mission Control|active mission binding|active mission|project scoped mission|Mission Control.*project|Mission Control.*read-only' \
  docs/architecture docs/checkpoints docs/*.md 2>/dev/null | head -500 || true

printf '\n=== REMAINING MISSION CONTROL CORRIDOR MAP ===\n'
sed -n '1,220p' docs/architecture/MISSION_CONTROL_PHASE_CORRIDORS.md 2>/dev/null || true

printf '\n=== ACTIVE MISSION CLIENT / PROVIDER STATE ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'ACTIVE_PACKAGE_ID|loadMission\(|lastPackageId|activeProjectId|useProjectContext|MissionControlProvider' \
  client/src 2>/dev/null | head -420 || true

printf '\n=== PROJECT-SCOPING SURFACES THAT DO NOT REQUIRE OPERATIONAL INFERENCE ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'project_id|activeProjectId|project scoped|project-scoped' \
  routes/api-mission-read.ts \
  db/mission-read-repository.ts \
  client/src/mission-control \
  client/src/shell/MissionDashboardWorkspace.tsx \
  2>/dev/null | head -420 || true

printf '\n=== PHASE DECISION GATE ===\n'
printf '%s\n' \
'QUESTION_1=Is there any remaining Mission Control work in this phase that can be completed without selecting or inventing downstream operational state?' \
'QUESTION_2=Can project isolation itself be improved safely while active mission selection remains blocked?' \
'QUESTION_3=Would any candidate Corridor 5 merely restate or work around the upstream governance-runtime dependency?' \
'QUESTION_4=Does the canonical corridor map require a bounded validation/closure step after the dependency classification?' \
'IF_SAFE_PROJECT_ISOLATION_WORK_EXISTS=CLASSIFY_CORRIDOR_5_WITHOUT_ACTIVE_MISSION_INFERENCE' \
'IF_ONLY_DEPENDENCY_WORK_REMAINS=CLOSE_PHASE_BLOCKED_BY_UPSTREAM_GOVERNANCE_RUNTIME_ACTIVATION' \
'IF_VALIDATION_ONLY_REMAINS=CLASSIFY_FINAL_VALIDATION_AND_CLOSURE_CORRIDOR' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
