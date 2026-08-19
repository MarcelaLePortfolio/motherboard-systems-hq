#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=PIPELINE_POSITION' \
  'PIPELINE_BOUNDARY=GOVERNANCE_MOVEMENT_ONLY' \
  'DEPARTMENT_OR_AGENT_INFERENCE=PROHIBITED' \
  'VALIDATION_PURPOSE=CONFIRM_IMPLEMENTATION_BEFORE_CORRIDOR_CLOSURE'

printf '\n=== IMPLEMENTATION CHECKPOINT ===\n'
git log -5 --oneline --decorate

printf '\n=== PIPELINE COMPONENT PRESENT ===\n'
grep -n -A55 -B5 'function MissionPipelineCard' \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== PIPELINE RENDER PRESENT ===\n'
grep -n -A12 -B5 'aria-label="Mission pipeline position"' \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== AUTHORITY BOUNDARY CHECK ===\n'
if grep -n -E 'assigned_department|assigned_agent' \
  client/src/shell/MissionDashboardWorkspace.tsx; then
  echo 'PIPELINE_AUTHORITY_BOUNDARY=FAIL'
  exit 1
else
  echo 'PIPELINE_AUTHORITY_BOUNDARY=PASS'
fi

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== BACKEND REGRESSION VALIDATION ===\n'
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== LIVE MISSION POSITION ===\n'
npx tsx scripts/validate-mission-state-projection-live.ts

printf '\n=== CORRIDOR 3 VALIDATION RESULT ===\n'
echo 'PIPELINE_COMPONENT=PASS'
echo 'GOVERNANCE_ONLY_BOUNDARY=PASS'
echo 'CLIENT_BUILD=PASS'
echo 'BACKEND_REGRESSION=PASS'
echo 'LIVE_MISSION_READ=PASS'
echo 'CORRIDOR_3_CLOSURE_READY=YES'

printf '\n=== WORKTREE ===\n'
git status --short
