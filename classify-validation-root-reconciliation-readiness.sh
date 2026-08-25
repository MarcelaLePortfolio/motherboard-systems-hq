#!/usr/bin/env bash
set -euo pipefail

echo "=== VALIDATION ROOT RECONCILIATION — READINESS CLASSIFICATION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== DELEGATION MIGRATION PATTERN ==="
sed -n '1,260p' scripts/migrate-delegation-root-to-canonical.sh

echo
echo "=== CURRENT VALIDATION TABLE ==="
sqlite3 db/main.db ".schema governance_validation_results"

echo
echo "=== CURRENT VALIDATION ROWS ==="
sqlite3 -header -column db/main.db "
SELECT
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status
FROM governance_validation_results
ORDER BY created_at DESC;
"

echo
echo "=== VALIDATION ROW CANONICAL-LINEAGE COMPATIBILITY ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id,
  v.package_version,
  v.delegation_id,
  CASE WHEN c.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS canonical_package_exists,
  CASE WHEN d.delegation_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS delegation_exists,
  d.authorization_state
FROM governance_validation_results v
LEFT JOIN matilda_canonical_packages c
  ON c.package_id = v.package_id
 AND c.package_version = v.package_version
LEFT JOIN governance_delegations d
  ON d.delegation_id = v.delegation_id
ORDER BY v.created_at DESC;
"

echo
echo "=== DEPENDENTS OF VALIDATION ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  COUNT(DISTINCT g.envelope_gate_id) AS envelope_gate_dependents,
  COUNT(DISTINCT e.envelope_id) AS envelope_dependents
FROM governance_validation_results v
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id
GROUP BY v.validation_result_id;
"

echo
echo "=== RUNTIME WRITE BOUNDARY ==="
sed -n '811,900p' db/governance-runtime.ts

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=DELEGATION_CANONICAL_ROOT_COMPLETE"
echo "CURRENT_BOUNDARY=GOVERNANCE_VALIDATION_RESULTS_PACKAGE_ROOT"
echo "TARGET_ROOT=MATILDA_CANONICAL_PACKAGES"
echo "AUTHORITY_CHANGE_INTENDED=NO"
echo "VALIDATION_SEMANTICS_CHANGE_INTENDED=NO"
echo "DOWNSTREAM_GATE_MIGRATION_INCLUDED=NO"
echo "DOWNSTREAM_ENVELOPE_MIGRATION_INCLUDED=NO"
echo "OPERATIONAL_INTAKE_MIGRATION_INCLUDED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "READINESS_QUESTION=CAN_VALIDATION_PACKAGE_ROOT_BE_RECONCILED_IN_ISOLATION_WITH_EXISTING_ROWS_AND_DOWNSTREAM_REFERENCES_PRESERVED"
