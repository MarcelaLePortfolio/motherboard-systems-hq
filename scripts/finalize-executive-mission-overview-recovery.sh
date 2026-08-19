#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'RECOVERY_STATE=PARTIAL_IMPLEMENTATION_RESTORED_IN_WORKTREE' \
  'FAILED_IMPLEMENTATION_COMMIT=4b681583' \
  'STABLE_IMPLEMENTATION_BASE=d403d0f2' \
  'FAILED_HYPOTHESIS=FRONTEND_MISSION_READ_CONTRACT_SHAPE_MATCH' \
  'FAILED_ATTEMPT_COUNT=1' \
  'NEXT_APPROACH=MATCH_ACTUAL_FRONTEND_MISSION_READ_MODEL_SHAPE'

printf '\n=== VERIFY RESTORED IMPLEMENTATION FILES MATCH STABLE BASE ===\n'
git diff --exit-code d403d0f2 -- \
  db/mission-read-model-assembler.ts \
  db/mission-read-model-types.ts \
  db/mission-read-repository.ts \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/missionPresentationMapper.ts \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== VERIFY FAILED IMPLEMENTATION SCRIPT REMOVED ===\n'
test ! -e scripts/implement-bounded-executive-mission-overview.sh

printf '\n=== CLIENT BASELINE VALIDATION ===\n'
npm run build --prefix client

printf '\n=== RECOVERY READY ===\n'
git status --short
