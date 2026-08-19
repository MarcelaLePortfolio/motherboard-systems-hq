#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=PIPELINE_POSITION'

printf '\n=== PIPELINE / PROGRESS PRESENTATION CONTRACT ===\n'
sed -n '50,95p' docs/claude-handoffs/MISSION_CONTROL_PRESENTATION_V1_CLAUDE_TASK.md
sed -n '150,185p' docs/MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md

printf '\n=== CURRENT PROGRESS MAPPER ===\n'
sed -n '1,240p' client/src/mission-control/missionPresentationMapper.ts

printf '\n=== CURRENT PIPELINE PRESENTATION ===\n'
sed -n '1,90p' docs/archive/mission-control-removed-cards-2026-07-30/MissionDashboardArchivedCards.tsx.txt

printf '\n=== AUTHORITATIVE ORGANIZATIONAL MOVEMENT SOURCES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'delegation|assigned_department|assigned_agent|routing|operational_intake|envelope_id|lifecycle_state' \
  db server routes 2>/dev/null | head -260

printf '\n=== LIVE PIPELINE EVIDENCE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.requested_outcome,
  d.authorization_state AS delegation_state,
  e.lifecycle_state,
  oi.assigned_department
FROM governance_packages p
LEFT JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_envelopes e
  ON e.package_id = p.package_id
 AND e.package_version = p.package_version
LEFT JOIN operational_intake oi
  ON oi.envelope_id = e.envelope_id
ORDER BY p.created_at DESC
LIMIT 10;
"
