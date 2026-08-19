#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '\n=== EXECUTIVE BRIEF TITLE MAPPING CONTRACT ===\n'
sed -n '95,150p' docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md

printf '\n=== PRESENTATION RECONCILIATION ===\n'
sed -n '1,120p' docs/mission-control/MISSION_CONTROL_PRESENTATION_RECONCILIATION_2026-07-31.md

printf '\n=== REQUESTED OUTCOME CURRENT MISSION READ GAP ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'requested_outcome|Mission title not yet available|mission objective' \
  db/mission-read-* client/src/mission-control client/src/shell/MissionDashboardWorkspace.tsx \
  2>/dev/null || true
