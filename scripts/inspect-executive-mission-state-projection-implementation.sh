#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=EXECUTIVE_OVERVIEW_VALIDATION_AND_CLOSURE' \
  'CURRENT_IMPLEMENTATION_UNIT=MISSION_STATE_PROJECTION' \
  'REQUESTED_OUTCOME_UNIT_CHECKPOINT=3c8b4de9' \
  'IMPLEMENTATION_AUTHORIZED=YES' \
  'NEXT_ACTION=BOUND_STATE_PROJECTION_IMPLEMENTATION_FROM_LIVE_GOVERNANCE_TABLES'

printf '\n=== CURRENT MISSION READ ASSEMBLER ===\n'
sed -n '1,220p' db/mission-read-model-assembler.ts

printf '\n=== CURRENT MISSION READ REPOSITORY ===\n'
sed -n '1,220p' db/mission-read-repository.ts

printf '\n=== GOVERNANCE STATE TABLE SCHEMAS ===\n'
sqlite3 db/main.db ".schema governance_delegations"
sqlite3 db/main.db ".schema governance_validation_results"
sqlite3 db/main.db ".schema governance_envelope_gates"
sqlite3 db/main.db ".schema governance_envelopes"

printf '\n=== LIVE STATE VALUES ===\n'
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
WHERE p.package_id = 'corridor-smoke';
"

printf '\n=== STATE TEST EXPECTATIONS ===\n'
sed -n '1,260p' db/mission-read-model-assembler.test.ts
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Awaiting Delegation|Governance Validation|Envelope Gate|ENVELOPE_CREATED|ASSIGNED|MissionOwner|MissionHealth|awaiting' \
  db docs client/src 2>/dev/null | head -220

printf '\n=== WORKTREE ===\n'
git status --short
