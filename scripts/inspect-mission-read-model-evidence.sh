#!/usr/bin/env bash
set -euo pipefail

printf '\n=== GOVERNANCE TABLE SCHEMAS ===\n'
for table in \
  governance_packages \
  governance_delegations \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes \
  governance_lifecycle_events
do
  printf '\n--- %s ---\n' "$table"
  sqlite3 db/main.db ".schema $table"
done

printf '\n=== DISTINCT GOVERNANCE STATUS VALUES ===\n'

printf '\n--- delegation authorization_state ---\n'
sqlite3 -header -column db/main.db "
SELECT authorization_state, COUNT(*) AS record_count
FROM governance_delegations
GROUP BY authorization_state
ORDER BY authorization_state;
"

printf '\n--- validation validation_status ---\n'
sqlite3 -header -column db/main.db "
SELECT validation_status, COUNT(*) AS record_count
FROM governance_validation_results
GROUP BY validation_status
ORDER BY validation_status;
"

printf '\n--- envelope gate gate_status ---\n'
sqlite3 -header -column db/main.db "
SELECT gate_status, COUNT(*) AS record_count
FROM governance_envelope_gates
GROUP BY gate_status
ORDER BY gate_status;
"

printf '\n--- envelope lifecycle states ---\n'
sqlite3 -header -column db/main.db "
SELECT lifecycle_state, COUNT(*) AS record_count
FROM governance_envelopes
GROUP BY lifecycle_state
ORDER BY lifecycle_state;
"

printf '\n=== GOVERNANCE RECORD COUNTS ===\n'
sqlite3 -header -column db/main.db "
SELECT 'governance_packages' AS artifact, COUNT(*) AS records
FROM governance_packages
UNION ALL
SELECT 'governance_delegations', COUNT(*) FROM governance_delegations
UNION ALL
SELECT 'governance_validation_results', COUNT(*) FROM governance_validation_results
UNION ALL
SELECT 'governance_envelope_gates', COUNT(*) FROM governance_envelope_gates
UNION ALL
SELECT 'governance_envelopes', COUNT(*) FROM governance_envelopes
UNION ALL
SELECT 'governance_lifecycle_events', COUNT(*) FROM governance_lifecycle_events;
"

printf '\n=== SAMPLE LINEAGE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  d.delegation_id,
  d.authorization_state,
  v.validation_status,
  g.gate_status,
  e.lifecycle_state
FROM governance_packages p
LEFT JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_validation_results v
  ON v.validation_result_id = d.delegation_id
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.envelope_gate_id = g.envelope_gate_id
LIMIT 20;
"

printf '\n=== PROJECT LINKAGE SEARCH ===\n'
grep -RInE \
'project_id|activeProject|active_project' \
db routes server \
--include='*.ts' \
--include='*.mjs' \
2>/dev/null || true

printf '\n=== ASSIGNMENT SEARCH ===\n'
grep -RInE \
'assignment|target_actor|department|operational_corridor' \
db routes server \
--include='*.ts' \
--include='*.mjs' \
2>/dev/null || true

printf '\n=== GOVERNANCE STATUS CONSTANTS ===\n'
grep -RInE \
'authorization_state|validation_status|gate_status|lifecycle_state|ENVELOPE_CREATED|ASSIGNED' \
db routes \
--include='*.ts' \
2>/dev/null || true

printf '\n=== REPOSITORY STATE ===\n'
git status --short
