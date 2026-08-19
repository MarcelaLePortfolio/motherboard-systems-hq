#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '\n=== CORRIDOR 2 STATE GAP CLASSIFICATION ===\n'

printf '\n--- MISSION READ STAGE COVERAGE ---\n'
sed -n '1,140p' db/mission-read-model-types.ts
sed -n '1,140p' db/mission-read-model-assembler.ts

printf '\n--- AUTHORITATIVE ASSIGNMENT / OWNER SOURCES ---\n'
sed -n '1,180p' db/matilda-assignment-runtime.ts
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'assigned_department|assigned_agent|assignment_id' \
  db server routes 2>/dev/null | head -180

printf '\n--- AUTHORITATIVE WAITING / BLOCKING SOURCES ---\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'awaiting|blocked|NEEDS_ATTENTION|integrity_warnings|gate_status|validation_status|authorization_state' \
  db server routes 2>/dev/null | head -220

printf '\n--- CURRENT MISSION READ REPOSITORY COVERAGE ---\n'
sed -n '1,180p' db/mission-read-repository.ts

printf '\n--- LIVE GOVERNANCE STATE ---\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.requested_outcome,
  d.authorization_state AS delegation_state,
  v.validation_status,
  g.gate_status,
  e.lifecycle_state,
  e.envelope_id
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
ORDER BY p.created_at DESC
LIMIT 10;
"
