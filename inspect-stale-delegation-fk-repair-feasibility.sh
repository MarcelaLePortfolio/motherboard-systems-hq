#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== STALE DELEGATION FK REPAIR FEASIBILITY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT FOREIGN KEYS ==="
for table in \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes
do
  echo "--- $table ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list($table);"
done

echo
echo "=== HISTORICAL ROW IDENTITY SNAPSHOT ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id AS validation_package_id,
  v.package_version AS validation_package_version,
  v.delegation_id AS validation_delegation_id,
  g.envelope_gate_id,
  g.package_id AS gate_package_id,
  g.package_version AS gate_package_version,
  g.delegation_id AS gate_delegation_id,
  e.envelope_id,
  e.package_id AS envelope_package_id,
  e.package_version AS envelope_package_version,
  e.delegation_id AS envelope_delegation_id
FROM governance_validation_results v
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id
WHERE v.validation_result_id = 'corridor-validation';
"

echo
echo "=== CURRENT DELEGATION MATCH ==="
sqlite3 -header -column db/main.db "
SELECT
  delegation_id,
  package_id,
  package_version,
  authorization_state,
  authorization_timestamp,
  delegated_by,
  created_at
FROM governance_delegations
WHERE delegation_id = 'corridor-delegation';
"

echo
echo "=== PACKAGE LINEAGE MUST REMAIN LEGACY ==="
sqlite3 -header -column db/main.db "
SELECT
  gp.package_id,
  gp.package_version,
  CASE WHEN cp.package_id IS NULL
    THEN 'NO_CANONICAL_MATCH'
    ELSE 'CANONICAL_MATCH'
  END AS canonical_overlap
FROM governance_packages gp
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = gp.package_id
 AND cp.package_version = gp.package_version
WHERE gp.package_id = 'corridor-smoke'
  AND gp.package_version = 1;
"

echo
echo "=== SCHEMA-ONLY REPAIR SIMULATION ON DISPOSABLE COPY ==="
TMP_DB="$(mktemp /tmp/governance-fk-repair.XXXXXX)"
cp db/main.db "$TMP_DB"

TMP_DB="$TMP_DB" node <<'NODE'
const Database = require("better-sqlite3");

const path = process.env.TMP_DB;
if (!path) {
  throw new Error("TMP_DB is required");
}

const db = new Database(path);

db.pragma("foreign_keys = OFF");

const tx = db.transaction(() => {
  db.exec(`
    CREATE TABLE governance_validation_results_new (
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
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id)
    );

    INSERT INTO governance_validation_results_new
    SELECT * FROM governance_validation_results;

    CREATE TABLE governance_envelope_gates_new (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results_new(validation_result_id)
    );

    INSERT INTO governance_envelope_gates_new
    SELECT * FROM governance_envelope_gates;

    CREATE TABLE governance_envelopes_new (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results_new(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates_new(envelope_gate_id)
    );

    INSERT INTO governance_envelopes_new
    SELECT * FROM governance_envelopes;

    DROP TABLE governance_envelopes;
    DROP TABLE governance_envelope_gates;
    DROP TABLE governance_validation_results;

    ALTER TABLE governance_validation_results_new
      RENAME TO governance_validation_results;

    ALTER TABLE governance_envelope_gates_new
      RENAME TO governance_envelope_gates;

    ALTER TABLE governance_envelopes_new
      RENAME TO governance_envelopes;
  `);
});

tx();

db.pragma("foreign_keys = ON");

console.log("=== FOREIGN KEY CHECK AFTER SIMULATION ===");
console.log(db.prepare("PRAGMA foreign_key_check").all());

console.log("=== HISTORICAL VALIDATION AFTER SIMULATION ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_validation_results
    WHERE validation_result_id = 'corridor-validation'
  `).get()
);

console.log("=== HISTORICAL GATE AFTER SIMULATION ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_envelope_gates
    WHERE envelope_gate_id = 'corridor-gate'
  `).get()
);

console.log("=== HISTORICAL ENVELOPE AFTER SIMULATION ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_envelopes
    WHERE envelope_id = 'corridor-envelope'
  `).get()
);

db.close();
NODE

echo
echo "=== DISPOSABLE SCHEMA AFTER SIMULATION ==="
for table in \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes
do
  echo "--- $table ---"
  sqlite3 -header -column "$TMP_DB" "PRAGMA foreign_key_list($table);"
done

echo
echo "=== DISPOSABLE FOREIGN KEY CHECK ==="
sqlite3 -header -column "$TMP_DB" "PRAGMA foreign_key_check;"

rm -f "$TMP_DB"

echo
echo "=== CLASSIFICATION ==="
echo "CANDIDATE_DEFECT=STALE_DELEGATION_FOREIGN_KEYS_FROM_DELEGATION_ROOT_MIGRATION"
echo "PACKAGE_LINEAGE_CHANGE_REQUIRED=NO"
echo "HISTORICAL_PACKAGE_REPARENTING_REQUIRED=NO"
echo "HISTORICAL_VALIDATION_IDENTITY_CHANGE_REQUIRED=NO"
echo "HISTORICAL_GATE_IDENTITY_CHANGE_REQUIRED=NO"
echo "HISTORICAL_ENVELOPE_IDENTITY_CHANGE_REQUIRED=NO"
echo "TARGET_DELEGATION_PARENT=GOVERNANCE_DELEGATIONS"
echo "VALIDATION_SEMANTICS_CHANGE_REQUIRED=NO"
echo "NEW_VALIDATION_ACTIVATION_REQUIRED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "READINESS_QUESTION=CAN_SCHEMA_ONLY_REPAIR_CLOSE_THE_STALE_DELEGATION_FK_DEFECT_WITH_ZERO_HISTORICAL_IDENTITY_DRIFT"
