#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=MISSION_STATE_PROJECTION' \
  'CURRENT_CHECKPOINT=140ebbe3' \
  'FAILED_HYPOTHESIS=ENVELOPE_GATE_OPEN_REQUIRED_FOR_ENVELOPE_CREATED_HEALTH' \
  'FAILED_ATTEMPT_COUNT=2' \
  'NEXT_ACTION=RECONCILE_LIVE_GATE_STATE_WITH_ENFORCEMENT_CONTRACT'

printf '\n=== LIVE CORRIDOR-SMOKE GOVERNANCE LINEAGE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  d.authorization_state,
  v.validation_status,
  g.gate_status,
  g.gate_reason,
  e.lifecycle_state,
  e.created_at AS envelope_created_at
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

printf '\n=== GATE STATUS USAGE ACROSS REPOSITORY ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'gate_status.*PASSED|gate_status.*OPEN|gate_status.*CLOSED|gate_status.*APPROVED|normalizeLifecycleStatus\(gateStatus\)' \
  db server docs 2>/dev/null | head -220

printf '\n=== ENVELOPE CREATION ENFORCEMENT ===\n'
sed -n '80,160p' db/governance-lifecycle-enforcement.ts

printf '\n=== CURRENT INTEGRITY RULE ===\n'
grep -n -A35 -B5 'deriveIntegrityWarnings' db/mission-read-model-assembler.ts

printf '\n=== CURRENT WORKTREE ===\n'
git status --short
