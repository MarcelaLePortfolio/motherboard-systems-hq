#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=MISSION_STATE_PROJECTION'

printf '\n=== MISSION READ STATE DERIVATION ===\n'
sed -n '1,260p' db/mission-read-model-assembler.ts

printf '\n=== GOVERNANCE LIFECYCLE AUTHORITY ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'lifecycle_state|transition_authorization|AWAITING_DELEGATION|GOVERNANCE_VALIDATION|ENVELOPE_GATE|ENVELOPE_CREATED|ASSIGNED|RUNNING|COMPLETED' \
  db server routes docs 2>/dev/null | head -260

printf '\n=== EXECUTIVE MISSION STATE PRESENTATION ===\n'
sed -n '1,240p' client/src/mission-control/missionPresentationMapper.ts
sed -n '70,230p' client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== CURRENT LIVE MISSION EVIDENCE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  p.requested_outcome,
  e.lifecycle_state,
  e.envelope_id
FROM governance_packages p
LEFT JOIN governance_envelopes e
  ON e.package_id = p.package_id
 AND e.package_version = p.package_version
ORDER BY p.created_at DESC
LIMIT 10;
"
