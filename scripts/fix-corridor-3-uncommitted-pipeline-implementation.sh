#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git add \
  client/src/shell/MissionDashboardWorkspace.tsx \
  scripts/implement-executive-mission-pipeline-position.sh

git commit -m "Implement Executive Mission pipeline position"
git push
