#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=EXECUTIVE_OVERVIEW_VALIDATION_AND_CLOSURE' \
  'IMPLEMENTATION_UNIT=REQUESTED_OUTCOME_PROJECTION' \
  'RECOVERY_BASE=e514257b'

printf '\n=== CURRENT CHECKPOINT ===\n'
git log -5 --oneline --decorate

printf '\n=== IMPLEMENTATION SURFACE ===\n'
grep -n -E 'requested_outcome|requestedOutcome' \
  db/mission-read-model-types.ts \
  db/mission-read-model-assembler.ts \
  db/mission-read-repository.ts \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/missionPresentationMapper.ts \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== PLACEHOLDER ABSENCE ===\n'
if grep -n -E 'Mission title not yet available|Mission objective is not yet exposed' \
  client/src/shell/MissionDashboardWorkspace.tsx; then
  echo 'PLACEHOLDER_REMOVAL=FAIL'
  exit 1
else
  echo 'PLACEHOLDER_REMOVAL=PASS'
fi

printf '\n=== BACKEND VALIDATION ===\n'
npx tsx db/mission-read-model-assembler.test.ts
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== CLIENT VALIDATION ===\n'
npm run build --prefix client

printf '\n=== LIVE MISSION READ SOURCE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  requested_outcome
FROM governance_packages
WHERE package_id = 'corridor-smoke';
"

printf '\n=== WORKTREE ===\n'
git status --short
