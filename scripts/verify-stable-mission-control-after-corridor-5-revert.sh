#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CORRIDOR 5 POST-REVERT STABILITY VERIFICATION ===\n'
printf 'REVERT_COMMIT=93dbb947\n'
printf 'STABLE_RUNTIME_BASE=c828acb8\n\n'

git diff --exit-code c828acb8 -- \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/shell/WorkspaceMount.tsx

printf '\nRUNTIME_FILES_MATCH_STABLE_BASE=YES\n'
printf 'LIVE_UI_VERIFICATION_REQUIRED=YES\n'
printf 'EXPECTED_UI=FULL_MISSION_CONTROL_DASHBOARD\n'
printf 'NEW_IMPLEMENTATION_AUTHORIZED=NO\n'
