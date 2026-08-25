#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION MINIMUM DATABASE-ENFORCED COEXISTENCE MODEL ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED EVIDENCE ==="
echo "LEGACY_VALIDATION_READ_LINEAGE_REQUIRED=YES"
echo "LEGACY_VALIDATION_CANONICAL_AUTHORITY=NO"
echo "NEW_VALIDATION_REQUIRES_CANONICAL_PACKAGE_AUTHORITY=YES"
echo "NEW_VALIDATION_REQUIRES_CANONICAL_DELEGATION_AUTHORITY=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT VALIDATION SCHEMA ==="
sqlite3 db/main.db ".schema governance_validation_results"

echo
echo "=== CURRENT VALIDATION FOREIGN KEYS ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_validation_results);"

echo
echo "=== CURRENT HISTORICAL VALIDATION ROW ==="
sqlite3 -header -column db/main.db "
SELECT validation_result_id, package_id, package_version, delegation_id, validation_status
FROM governance_validation_results
ORDER BY created_at;
"

echo
echo "=== CANONICAL PACKAGE INVENTORY ==="
sqlite3 -header -column db/main.db "
SELECT package_id, package_version, status, created_at
FROM matilda_canonical_packages
ORDER BY created_at;
"

echo
echo "=== CURRENT DELEGATION INVENTORY ==="
sqlite3 -header -column db/main.db "
SELECT
  d.delegation_id,
  d.package_id,
  d.package_version,
  d.authorization_state,
  CASE WHEN cp.package_id IS NOT NULL THEN 'CANONICAL' ELSE 'NONCANONICAL' END AS root_class
FROM governance_delegations d
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = d.package_id
 AND cp.package_version = d.package_version
ORDER BY d.created_at;
"

echo
echo "=== VALIDATION WRITE CONTRACT ==="
sed -n '811,930p' db/governance-runtime.ts

echo
echo "=== DATABASE ENFORCEMENT CLASSIFICATION ==="
echo "SQLITE_SINGLE_FOREIGN_KEY_CAN_REFERENCE_TWO_PACKAGE_ROOTS=NO"
echo "ONE_TABLE_WITH_ONLY_CANONICAL_PACKAGE_FK_PRESERVES_CORRIDOR_SMOKE=NO"
echo "ONE_TABLE_WITH_ONLY_LEGACY_PACKAGE_FK_ENFORCES_NEW_CANONICAL_AUTHORITY=NO"
echo "ONE_TABLE_WITHOUT_PACKAGE_FK_PRESERVES_DATABASE_ENFORCEMENT=NO"
echo "APPLICATION_ONLY_LINEAGE_GUARD_PRESERVES_DATABASE_ENFORCEMENT=NO"

echo
echo "=== DISPOSABLE SEPARATE-CANONICAL-SURFACE TEST ==="
TMP_DB="$(mktemp -t validation-minimum-coexistence).db"
cp db/main.db "$TMP_DB"

TMP_DB="$TMP_DB" node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database(process.env.TMP_DB);

db.exec(`
  CREATE TABLE governance_canonical_validation_results (
    validation_result_id TEXT PRIMARY KEY,
    package_id TEXT NOT NULL,
    package_version INTEGER NOT NULL,
    delegation_id TEXT NOT NULL,
    validation_status TEXT NOT NULL,
    governance_findings TEXT,
    operational_requirements TEXT,
    capability_requirements TEXT,
    escalations TEXT,
    validation_timestamp TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (package_id, package_version)
      REFERENCES matilda_canonical_packages(package_id, package_version),
    FOREIGN KEY (delegation_id)
      REFERENCES governance_delegations(delegation_id)
  );
`);

const historical = db.prepare(`
  SELECT validation_result_id, package_id, package_version, delegation_id
  FROM governance_validation_results
  WHERE validation_result_id = 'corridor-validation'
`).get();

if (!historical) throw new Error("Historical Validation row missing.");

if (
  historical.package_id !== "corridor-smoke" ||
  historical.package_version !== 1 ||
  historical.delegation_id !== "corridor-delegation"
) {
  throw new Error("Historical Validation lineage drifted.");
}

console.log("SEPARATE_CANONICAL_VALIDATION_TABLE_SCHEMA=PASS");
console.log("LEGACY_VALIDATION_ROW_REMAINS_UNCHANGED=PASS");

db.close();
NODE

rm -f "$TMP_DB"

echo
echo "=== READER / WRITER IMPACT ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FROM governance_validation_results|JOIN governance_validation_results|INSERT INTO governance_validation_results|createGovernanceValidationResult' \
  db server routes scripts \
  2>/dev/null | head -n 2400

echo
echo "=== CURRENT FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== CLASSIFICATION ==="
echo "OPTION_SINGLE_TABLE_CANONICAL_REPARENT=REJECTED_FALSE_HISTORICAL_LINEAGE"
echo "OPTION_SINGLE_TABLE_LEGACY_ROOT=REJECTED_NO_DATABASE_ENFORCED_CANONICAL_AUTHORITY"
echo "OPTION_APPLICATION_ONLY_GUARD=REJECTED_WEAKENS_DATABASE_AUTHORITY"
echo "OPTION_SEPARATE_CANONICAL_VALIDATION_TABLE=STRUCTURALLY_COMPATIBLE"
echo "SEPARATE_CANONICAL_VALIDATION_TABLE_ARCHITECTURALLY_SELECTED=NOT_YET"
echo "READ_COMPATIBILITY_MODEL_REQUIRED=YES_IF_SEPARATE_CANONICAL_TABLE_SELECTED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=FALSIFY_SEPARATE_CANONICAL_VALIDATION_PERSISTENCE_AGAINST_RUNTIME_OWNERSHIP_READER_SEMANTICS_AND_DOWNSTREAM_VALIDATION_RESULT_ID_REQUIREMENTS"
