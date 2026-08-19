#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=EXECUTIVE_OVERVIEW_VALIDATION_AND_CLOSURE'

printf '\n=== CORRIDOR CLASSIFICATION CHECKPOINTS ===\n'
git log --oneline --decorate -12

printf '\n=== EXECUTIVE OVERVIEW ACTIVE SURFACE ===\n'
sed -n '75,230p' client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== MISSION READ CONTRACT / REPOSITORY / ASSEMBLER ===\n'
sed -n '1,180p' db/mission-read-model-types.ts
sed -n '1,180p' db/mission-read-repository.ts
sed -n '1,180p' db/mission-read-model-assembler.ts

printf '\n=== EXECUTIVE OVERVIEW REQUIREMENTS ===\n'
sed -n '95,175p' docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md
sed -n '138,180p' docs/MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md

printf '\n=== CURRENT LIVE MISSION READ FIXTURE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  p.requested_outcome,
  d.authorization_state AS delegation_state,
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

printf '\n=== BOUNDED VALIDATION ===\n'
npm test -- --runInBand 2>/dev/null || true
npm run build --prefix client

printf '\n=== WORKTREE ===\n'
git status --short
