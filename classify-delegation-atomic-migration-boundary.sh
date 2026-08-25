#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DELEGATION HISTORICAL SEPARATION — ATOMIC MIGRATION BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED STARTING DETERMINATION ==="
echo "DELEGATION_ONLY_SEPARATION_SUFFICIENT=NO"
echo "REASON=DOWNSTREAM_TABLE_SCHEMAS_RETAIN_FOREIGN_KEYS_TO_GOVERNANCE_DELEGATIONS_LEGACY_ROOT"
echo "CANONICAL_DELEGATION_RUNTIME_CHANGE_REQUIRED=NO"
echo "CANONICAL_DELEGATION_WRITE_CHANGE_REQUIRED=NO"
echo "QUESTION=WHAT_IS_THE_MINIMUM_ATOMIC_SCHEMA_MIGRATION_THAT_PRESERVES_HISTORICAL_LINEAGE_WHILE_REPAIRING_DOWNSTREAM_DELEGATION_FOREIGN_KEYS"

echo
echo "=== EXACT CURRENT TABLE SQL ==="
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

for (const table of [
  "governance_delegations",
  "governance_validation_results",
  "governance_envelope_gates",
  "governance_envelopes",
  "operational_intake_records",
]) {
  console.log(`\n=== ${table} ===`);
  const row = db.prepare(`
    SELECT sql
    FROM sqlite_master
    WHERE type = 'table'
      AND name = ?
  `).get(table);
  console.log(row ? row.sql : "TABLE_NOT_PRESENT");
}

db.close();
NODE

echo
echo "=== EXACT CURRENT FOREIGN KEYS ==="
for table in \
  governance_delegations \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes \
  operational_intake_records
do
  echo "--- $table ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list($table);"
done

echo
echo "=== LEGACY ROOT TABLE EXISTENCE ==="
sqlite3 -header -column db/main.db "
SELECT
  name,
  type,
  sql
FROM sqlite_master
WHERE name IN (
  'governance_delegations',
  'governance_delegations_legacy_root',
  'governance_delegations_historical'
)
ORDER BY name;
"

echo
echo "=== CURRENT LINEAGE ROWS ==="
sqlite3 -header -column db/main.db "
SELECT
  gd.delegation_id,
  gd.package_id,
  gd.package_version,
  CASE
    WHEN cp.package_id IS NOT NULL THEN 'AUTHORITATIVE_CANONICAL'
    WHEN gp.package_id IS NOT NULL THEN 'HISTORICAL_LEGACY'
    ELSE 'UNRESOLVED'
  END AS lineage_class
FROM governance_delegations gd
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = gd.package_id
 AND cp.package_version = gd.package_version
LEFT JOIN governance_packages gp
  ON gp.package_id = gd.package_id
 AND gp.package_version = gd.package_version
ORDER BY gd.created_at;
"

echo
echo "=== DOWNSTREAM ROWS GROUPED BY DELEGATION ==="
sqlite3 -header -column db/main.db "
SELECT
  'validation' AS artifact_type,
  validation_result_id AS artifact_id,
  package_id,
  package_version,
  delegation_id
FROM governance_validation_results
UNION ALL
SELECT
  'gate',
  envelope_gate_id,
  package_id,
  package_version,
  delegation_id
FROM governance_envelope_gates
UNION ALL
SELECT
  'envelope',
  envelope_id,
  package_id,
  package_version,
  delegation_id
FROM governance_envelopes
ORDER BY delegation_id, artifact_type, artifact_id;
"

echo
echo "=== ACTIVE SOURCE SCHEMA CONTRACTS ==="
rg -n -C 24 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE TABLE IF NOT EXISTS governance_(delegations|validation_results|envelope_gates|envelopes)|CREATE TABLE IF NOT EXISTS operational_intake_records' \
  db \
  2>/dev/null | head -n 2200

echo
echo "=== ACTIVE WRITE-TIME LINEAGE VALIDATION ==="
rg -n -C 18 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createGovernanceValidation|createGovernanceEnvelopeGate|createGovernanceEnvelope|delegation_id|Canonical Package' \
  db/governance-runtime.ts db/operational-intake-runtime.ts \
  2>/dev/null | head -n 2600

echo
echo "=== MIGRATION HISTORY AFFECTING DOWNSTREAM FOREIGN KEYS ==="
git log --all --format='%H %ad %s' --date=iso \
  -S'governance_delegations_legacy_root' -- db scripts | head -n 160

echo
echo "=== CURRENT DATABASE INTEGRITY ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=DELEGATION_ONLY_HISTORICAL_SEPARATION_IS_NOT_A_COMPLETE_SCHEMA_RECONCILIATION"
echo "VERIFIED_OUTCOME=STALE_DOWNSTREAM_FOREIGN_KEYS_WERE_CREATED_BY_PRIOR_TABLE_RENAME_MIGRATION"
echo "REQUIRED_BOUNDARY=ATOMIC_DELEGATION_HISTORY_SEPARATION_PLUS_DOWNSTREAM_DELEGATION_FK_REPAIR"
echo "AUTHORITATIVE_DELEGATION_PARENT=MATILDA_CANONICAL_PACKAGES"
echo "HISTORICAL_DELEGATION_PARENT=GOVERNANCE_PACKAGES"
echo "HISTORICAL_IDENTITY_CHANGE_ALLOWED=NO"
echo "HISTORICAL_PACKAGE_REPARENTING_ALLOWED=NO"
echo "DOWNSTREAM_SEMANTIC_REPARENTING_ALLOWED=NO"
echo "DOWNSTREAM_TABLE_REBUILD_ALLOWED=NOT_YET_AUTHORIZED"
echo "VALIDATION_SEMANTICS_CHANGE_ALLOWED=NO"
echo "GATE_SEMANTICS_CHANGE_ALLOWED=NO"
echo "ENVELOPE_SEMANTICS_CHANGE_ALLOWED=NO"
echo "OPERATIONAL_INTAKE_SEMANTICS_CHANGE_ALLOWED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_WHETHER_HISTORICAL_DOWNSTREAM_ROWS_MUST_MOVE_WITH_THE_LEGACY_DELEGATION_OR_CAN_REMAIN_IN_EXISTING_TABLES_WITH_A_SAFE_DUAL_HISTORY_REFERENCE_PATTERN"
