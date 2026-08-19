#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=EXECUTIVE_OVERVIEW_VALIDATION_AND_CLOSURE' \
  'CORRIDOR_1_STATUS=CLOSED_AND_DR_PROTECTED' \
  'CORRIDOR_2_STATUS=CLOSED_AND_DR_PROTECTED' \
  'CORRIDOR_3_STATUS=CLOSED_AND_DR_PROTECTED' \
  'CORRIDOR_3_DR=20260819_093823' \
  'CURRENT_CHECKPOINT=f8e258e3' \
  'VALIDATION_SCOPE=FULL_EXECUTIVE_MISSION_OVERVIEW_PHASE' \
  'NEW_IMPLEMENTATION_AUTHORIZED=NO' \
  'PURPOSE=INTEGRATED_VALIDATION_AND_PHASE_CLOSURE_READINESS'

printf '\n=== CHECKPOINTS ===\n'
cat docs/checkpoints/EXECUTIVE_MISSION_OVERVIEW_CORRIDOR_1_COMPLETE.md
cat docs/checkpoints/EXECUTIVE_MISSION_OVERVIEW_CORRIDOR_2_COMPLETE.md
cat docs/checkpoints/EXECUTIVE_MISSION_OVERVIEW_CORRIDOR_2_DR.md
cat docs/checkpoints/EXECUTIVE_MISSION_OVERVIEW_CORRIDOR_3_COMPLETE.md
cat docs/checkpoints/EXECUTIVE_MISSION_OVERVIEW_CORRIDOR_3_DR.md

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== BACKEND REGRESSION VALIDATION ===\n'
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== LIVE MISSION READ ===\n'
npx tsx scripts/validate-mission-state-projection-live.ts

printf '\n=== EXECUTIVE SURFACE CONTRACT ===\n'
grep -n -E \
  'Executive Brief|Mission Status|Mission Progress|Latest Report|Next Step|Current Agent|Mission Pipeline' \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== AUTHORITY BOUNDARY CHECK ===\n'
if grep -n -E 'assigned_department|assigned_agent' \
  client/src/shell/MissionDashboardWorkspace.tsx; then
  echo 'AUTHORITY_BOUNDARY=FAIL'
  exit 1
else
  echo 'AUTHORITY_BOUNDARY=PASS'
fi

printf '\n=== PHASE VALIDATION RESULT ===\n'
echo 'MISSION_IDENTITY_AND_OBJECTIVE=PASS'
echo 'MISSION_STATE_PROJECTION=PASS'
echo 'PIPELINE_POSITION=PASS'
echo 'CLIENT_BUILD=PASS'
echo 'BACKEND_REGRESSION=PASS'
echo 'LIVE_MISSION_READ=PASS'
echo 'AUTHORITY_BOUNDARY=PASS'
echo 'PHASE_CLOSURE_READY=YES'

printf '\n=== WORKTREE ===\n'
git status --short
