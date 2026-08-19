#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=EXECUTIVE_OVERVIEW_VALIDATION_AND_CLOSURE' \
  'FAILED_HYPOTHESIS=FRONTEND_MISSION_READ_CONTRACT_SHAPE_MATCH' \
  'FAILED_ATTEMPT_COUNT_FOR_HYPOTHESIS=1' \
  'PARTIAL_IMPLEMENTATION_COMMIT=4b681583' \
  'ROLLBACK_BASE=d403d0f2' \
  'NEXT_ACTION=INSPECT_PARTIAL_COMMIT_BEFORE_ANY_FURTHER_IMPLEMENTATION'

printf '\n=== PARTIAL COMMIT FILES ===\n'
git show --stat --oneline 4b681583
git diff --name-status d403d0f2..4b681583

printf '\n=== FRONTEND CONTRACT ACTUAL SHAPE ===\n'
sed -n '1,220p' client/src/mission-control/missionReadApi.ts

printf '\n=== PARTIAL IMPLEMENTATION STATE ===\n'
git diff d403d0f2..4b681583 -- \
  db/mission-read-model-types.ts \
  db/mission-read-repository.ts \
  db/mission-read-model-assembler.ts \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/missionPresentationMapper.ts \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== BUILD / TYPECHECK ===\n'
npm run build --prefix client || true

printf '\n=== WORKTREE ===\n'
git status --short
