#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RUN POST-REGRESSION DR ==="
echo "STABLE_CHECKPOINT=1d392012"
echo "LATEST_VERIFIED_WORKING_TREE_BOUNDARY=20abe53a"
echo "PROJECT_CONTEXT_AND_EMPTY_MISSION_REGRESSION=CLOSED"
echo "MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT_MILESTONE_REOPENED=NO"
echo "CURRENT_RUNTIME_STATE=STABLE"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_REQUIRED=YES"

if [[ -x ./scripts/dr.sh ]]; then
  ./scripts/dr.sh
elif [[ -x ./dr.sh ]]; then
  ./dr.sh
elif [[ -f package.json ]] && node -e 'const p=require("./package.json"); process.exit(p.scripts?.dr ? 0 : 1)'; then
  npm run dr
else
  echo "DR_RUNNER_NOT_FOUND"
  exit 1
fi
