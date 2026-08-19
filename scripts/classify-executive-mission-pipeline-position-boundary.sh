#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=PIPELINE_POSITION' \
  'CORRIDOR_2_DR=20260819_091756' \
  'CURRENT_CHECKPOINT=219c38f9' \
  'LIVE_GOVERNANCE_PIPELINE_AUTHORITY=AVAILABLE' \
  'LIVE_OPERATIONAL_INTAKE_AUTHORITY=NOT_AVAILABLE_IN_MAIN_DB' \
  'LIVE_DEPARTMENT_ASSIGNMENT_AUTHORITY=NOT_AVAILABLE_IN_MAIN_DB' \
  'LIVE_AGENT_ASSIGNMENT_AUTHORITY=NOT_AVAILABLE_IN_MAIN_DB' \
  'PIPELINE_POSITION_BOUNDARY=GOVERNANCE_MOVEMENT_ONLY' \
  'SUPPORTED_PIPELINE_POSITION=PACKAGE_TO_DELEGATION_TO_VALIDATION_TO_GATE_TO_ENVELOPE' \
  'DEPARTMENT_POSITION_INFERENCE=PROHIBITED' \
  'AGENT_POSITION_INFERENCE=PROHIBITED' \
  'MISSION_PROGRESS_AND_PIPELINE=MUST_REMAIN_DISTINCT' \
  'NEW_SEMANTIC_AUTHORITY_REQUIRED=NO' \
  'NEW_PERSISTENCE_REQUIRED=NO' \
  'CORRIDOR_3_IMPLEMENTATION_SCOPE=EXECUTIVE_PRESENTATION_OF_EXISTING_GOVERNANCE_POSITION_ONLY' \
  'CORRIDOR_3_IMPLEMENTATION_READINESS=READY_BOUNDED' \
  'NEXT_ACTION=INSPECT_ARCHIVED_PIPELINE_COMPONENT_FOR_SAFE_REUSE'

printf '\n=== VERIFY LIVE AUTHORITY BOUNDARY ===\n'
sqlite3 db/main.db ".tables"

printf '\n=== VERIFY CURRENT GOVERNANCE POSITION ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
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
LIMIT 1;
"

printf '\n=== ARCHIVED PIPELINE COMPONENT LOCATION ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'function MissionPipeline|Mission Pipeline|mission-pipeline__node' \
  docs/archive client/src 2>/dev/null | head -160

printf '\n=== WORKTREE ===\n'
git status --short
