#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR_2_STATUS=CLOSED_AND_DR_PROTECTED' \
  'CORRIDOR_2_DR=20260819_091756' \
  'CORRIDOR_2_CHECKPOINT=cf66c349' \
  'ACTIVE_CORRIDOR=PIPELINE_POSITION' \
  'IMPLEMENTATION_AUTHORIZED=YES' \
  'PIPELINE_BOUNDARY=GOVERNANCE_MOVEMENT_ONLY' \
  'DEPARTMENT_OR_AGENT_INFERENCE=PROHIBITED'

printf '\n=== CURRENT FRONTEND PIPELINE SURFACE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Mission Pipeline|Current Stage|Current Owner|Awaiting|Mission Progress|pipeline' \
  client/src 2>/dev/null | head -220

printf '\n=== CURRENT PRESENTATION MAPPER ===\n'
cat client/src/mission-control/missionPresentationMapper.ts

printf '\n=== CURRENT EXECUTIVE WORKSPACE ===\n'
cat client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== CURRENT MISSION READ CONTRACT ===\n'
cat client/src/mission-control/missionReadApi.ts
cat db/mission-read-model-types.ts

printf '\n=== AUTHORITATIVE GOVERNANCE PIPELINE VALUES ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  d.authorization_state,
  v.validation_status,
  g.gate_status,
  e.lifecycle_state
FROM governance_packages p
LEFT JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_validation_results v
  ON v.package_id = p.package_id
 AND v.package_version = p.package_version
LEFT JOIN governance_envelope_gates g
  ON g.package_id = p.package_id
 AND g.package_version = p.package_version
LEFT JOIN governance_envelopes e
  ON e.package_id = p.package_id
 AND e.package_version = p.package_version
WHERE p.package_id = 'corridor-smoke'
ORDER BY e.created_at ASC;
"

printf '\n=== OPERATIONAL INTAKE / ASSIGNMENT AUTHORITY CHECK ===\n'
sqlite3 db/main.db ".tables"
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'operational_intake_records|assigned_department|assigned_agent|matilda_assignments' \
  db server client/src 2>/dev/null | head -220

printf '\n=== WORKTREE ===\n'
git status --short
