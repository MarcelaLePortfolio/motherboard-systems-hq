#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'RECOVERY_ACTION=REVERT_PARTIAL_IMPLEMENTATION' \
  'FAILED_IMPLEMENTATION_COMMIT=4b681583' \
  'STABLE_IMPLEMENTATION_BASE=d403d0f2' \
  'FAILED_HYPOTHESIS=FRONTEND_MISSION_READ_CONTRACT_SHAPE_MATCH' \
  'FAILED_ATTEMPT_COUNT=1' \
  'REASON=IMPLEMENTATION_ABORTED_BEFORE_FRONTEND_PROJECTION_AND_VALIDATION' \
  'NEXT_APPROACH=MATCH_ACTUAL_FRONTEND_MISSION_READ_MODEL_SHAPE'

git restore --source=d403d0f2 -- \
  db/mission-read-model-assembler.ts \
  db/mission-read-model-types.ts \
  db/mission-read-repository.ts

rm -f scripts/implement-bounded-executive-mission-overview.sh

printf '\n=== RECOVERY DIFF ===\n'
git diff -- \
  db/mission-read-model-assembler.ts \
  db/mission-read-model-types.ts \
  db/mission-read-repository.ts \
  scripts/implement-bounded-executive-mission-overview.sh

printf '\n=== CLIENT BASELINE VALIDATION ===\n'
npm run build --prefix client

printf '\n=== RECOVERED WORKTREE ===\n'
git status --short
