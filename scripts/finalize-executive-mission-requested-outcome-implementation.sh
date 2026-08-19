#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=EXECUTIVE_OVERVIEW_VALIDATION_AND_CLOSURE' \
  'IMPLEMENTATION_UNIT=REQUESTED_OUTCOME_PROJECTION' \
  'IMPLEMENTATION_RESULT=PASS' \
  'BACKEND_REPOSITORY_TEST=PASS' \
  'BACKEND_INTEGRATION_TEST=PASS' \
  'CLIENT_BUILD=PASS' \
  'PLACEHOLDER_REMOVAL=PASS' \
  'MISSION_OBJECTIVE_SOURCE=GOVERNANCE_PACKAGES_REQUESTED_OUTCOME' \
  'MISSION_TITLE_SOURCE=HUMAN_READABLE_REQUESTED_OUTCOME' \
  'NEW_SEMANTIC_AUTHORITY=NO' \
  'NEW_PERSISTENCE=NO' \
  'FAILED_HYPOTHESIS_COUNT=1' \
  'FAILED_HYPOTHESIS=FRONTEND_MISSION_READ_CONTRACT_SHAPE_MATCH' \
  'RECOVERY_COMPLETED=YES' \
  'NEXT_UNIT=MISSION_STATE_PROJECTION_IMPLEMENTATION'

printf '\n=== CURRENT IMPLEMENTATION DIFF FROM RECOVERY BASE ===\n'
git diff --stat e514257b -- \
  db/mission-read-model-types.ts \
  db/mission-read-model-assembler.ts \
  db/mission-read-repository.ts \
  db/mission-read-repository.test.ts \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/missionPresentationMapper.ts \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== FINAL TARGETED VALIDATION ===\n'
npx tsx db/mission-read-model-assembler.test.ts
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts
npm run build --prefix client

printf '\n=== WORKTREE ===\n'
git status --short
