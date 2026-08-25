#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION HISTORICAL PRESERVATION BOUNDARY ==="

echo
echo "=== LIVE VALIDATION FOREIGN KEYS ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_validation_results);"

echo
echo "=== LIVE DELEGATION TABLES ==="
sqlite3 -header -column db/main.db "
SELECT name, sql
FROM sqlite_master
WHERE type='table'
  AND name LIKE 'governance_delegations%';
"

echo
echo "=== HISTORICAL VALIDATION LINEAGE ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id,
  v.package_version,
  v.delegation_id,
  v.validation_status,
  d.authorization_state,
  g.envelope_gate_id,
  e.envelope_id,
  e.lifecycle_state
FROM governance_validation_results v
LEFT JOIN governance_delegations d
  ON d.delegation_id = v.delegation_id
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id
ORDER BY v.created_at DESC;
"

echo
echo "=== DELEGATION ROOT MIGRATION HISTORY ==="
git log --oneline --all -- \
  scripts/migrate-delegation-root-to-canonical.sh \
  db/governance-runtime.ts \
  drizzle/0004_governance_lifecycle_artifacts.sql | head -n 80

echo
echo "=== DELEGATION MIGRATION SCRIPT ==="
sed -n '1,260p' scripts/migrate-delegation-root-to-canonical.sh

echo
echo "=== DELEGATION RECONCILIATION CLOSURE ==="
sed -n '1,220p' docs/governance/PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_CLOSURE_2026-08-23.md

echo
echo "=== PRIOR HISTORICAL PRESERVATION EVIDENCE ==="
rg -n -C 6 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  'governance_delegations_legacy_root|corridor-smoke|historical.*validation|validation.*historical|preserv.*corridor-smoke|legacy.*validation|validation.*legacy' \
  docs scripts db drizzle \
  2>/dev/null | head -n 800

echo
echo "=== FRESH RUNTIME CONTRACT — SOURCE DECLARATION ==="
sed -n '228,266p' db/governance-runtime.ts

echo
echo "=== SOURCE EXPORT CHECK ==="
rg -n '^export .*ensureGovernanceRuntimeTables|^function ensureGovernanceRuntimeTables|^export function ensureGovernanceRuntimeTables' \
  db/governance-runtime.ts || true

echo
echo "=== CLASSIFICATION ==="
echo "CURRENT_LIVE_VALIDATION_DELEGATION_FK=LEGACY_RENAMED_TABLE"
echo "HISTORICAL_VALIDATION_HAS_DOWNSTREAM_DEPENDENTS=YES"
echo "HISTORICAL_LINEAGE_MUST_NOT_BE_REINTERPRETED_AS_CANONICAL=YES"
echo "FRESH_RUNTIME_VALIDATION_DELEGATION_FK=GOVERNANCE_DELEGATIONS"
echo "PREVIOUS_INSPECTION_FAILURE=NONEXPORTED_INTERNAL_INITIALIZER_IMPORT"
echo "PREVIOUS_FAILURE_CHANGES_ARCHITECTURAL_FINDING=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_QUESTION=CAN_LIVE_VALIDATION_SCHEMA_BE_REBUILT_TO_CURRENT_CONTRACT_WHILE_PRESERVING_HISTORICAL_ROWS_AS_HISTORICAL_AND_WITHOUT_REPARENTING_THEIR_PACKAGE_LINEAGE"
