#!/usr/bin/env bash
set -euo pipefail

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
echo "=== FRESH DATABASE CONTRACT ==="
node --import tsx <<'NODE'
import Database from "better-sqlite3";
import { ensureGovernanceRuntimeTables } from "./db/governance-runtime.ts";

const db = new Database(":memory:");
db.pragma("foreign_keys = ON");

console.log("NOTE: in-memory direct initialization cannot use the module-global db/main.db runtime.");
console.log("Inspect db/governance-runtime.ts table declarations as authoritative fresh-runtime source.");
NODE

sed -n '228,266p' db/governance-runtime.ts

echo
echo "=== CLASSIFICATION ==="
echo "CURRENT_LIVE_VALIDATION_DELEGATION_FK=LEGACY_RENAMED_TABLE"
echo "HISTORICAL_VALIDATION_HAS_DOWNSTREAM_DEPENDENTS=YES"
echo "HISTORICAL_LINEAGE_MUST_NOT_BE_REINTERPRETED_AS_CANONICAL=YES"
echo "FRESH_RUNTIME_VALIDATION_DELEGATION_FK=GOVERNANCE_DELEGATIONS"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_QUESTION=CAN_LIVE_VALIDATION_SCHEMA_BE_REBUILT_TO_CURRENT_CONTRACT_WHILE_PRESERVING_HISTORICAL_ROWS_AS_HISTORICAL_AND_WITHOUT_REPARENTING_THEIR_PACKAGE_LINEAGE"
