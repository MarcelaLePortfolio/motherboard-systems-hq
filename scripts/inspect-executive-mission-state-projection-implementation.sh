#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR_1_STATUS=CLOSED_AND_DR_PROTECTED' \
  'CORRIDOR_1_DR=20260818_193830' \
  'CORRIDOR_1_CHECKPOINT=db8fcab8' \
  'ACTIVE_CORRIDOR=MISSION_STATE_PROJECTION' \
  'IMPLEMENTATION_AUTHORIZED=YES'

printf '\n=== CURRENT MISSION READ CONTRACT ===\n'
cat db/mission-read-model-types.ts

printf '\n=== CURRENT ASSEMBLER ===\n'
cat db/mission-read-model-assembler.ts

printf '\n=== CURRENT REPOSITORY ===\n'
cat db/mission-read-repository.ts

printf '\n=== AUTHORITATIVE GOVERNANCE STATE SCHEMAS ===\n'
sqlite3 db/main.db ".schema governance_delegations"
sqlite3 db/main.db ".schema governance_validation_results"
sqlite3 db/main.db ".schema governance_envelope_gates"
sqlite3 db/main.db ".schema governance_envelopes"

printf '\n=== LIVE GOVERNANCE STATE ===\n'
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
WHERE p.package_id = 'corridor-smoke';
"

printf '\n=== CURRENT STATE TESTS ===\n'
cat db/mission-read-model-assembler.test.ts
cat db/mission-read-model.integration.test.ts

printf '\n=== WORKTREE ===\n'
git status --short
