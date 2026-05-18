
#!/bin/bash

set -euo pipefail

echo "== PHASE 731 FINAL CLEAN-STATE AUDIT =="

echo

echo "Repository root:"

pwd

echo

echo "Branch:"

git branch --show-current

echo

echo "HEAD:"

git rev-parse --short HEAD

echo

echo "Working tree status:"

git status --short

echo

echo "Verify assertion harness:"

./phase731_assert_trend_engine.sh

echo

echo "Verify stress harness:"

./phase731_stress_trend_engine.sh

echo

echo "Recent phase 731 commits:"

git log --oneline --decorate -10

echo

echo "Synchronization state:"

git fetch origin

LOCAL=$(git rev-parse @)

REMOTE=$(git rev-parse @{u})

if [[ "$LOCAL" == "$REMOTE" ]]; then

  echo "SYNC STATUS: CLEAN"

else

  echo "SYNC STATUS: DIVERGED"

  exit 1

fi

echo

echo "PHASE 731 AUDIT RESULT: PASS"

