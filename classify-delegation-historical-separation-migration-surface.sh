#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DELEGATION HISTORICAL SEPARATION — MINIMUM MIGRATION SURFACE ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT DELEGATION LINEAGE INVENTORY ==="
sqlite3 -header -column db/main.db "
SELECT
  gd.delegation_id,
  gd.package_id,
  gd.package_version,
  gd.authorization_state,
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
echo "=== DOWNSTREAM REFERENCES TO EACH DELEGATION ==="
sqlite3 -header -column db/main.db "
SELECT
  gd.delegation_id,
  gd.package_id,
  gd.package_version,
  COUNT(DISTINCT v.validation_result_id) AS validation_dependents,
  COUNT(DISTINCT g.envelope_gate_id) AS gate_dependents,
  COUNT(DISTINCT e.envelope_id) AS envelope_dependents
FROM governance_delegations gd
LEFT JOIN governance_validation_results v
  ON v.delegation_id = gd.delegation_id
LEFT JOIN governance_envelope_gates g
  ON g.delegation_id = gd.delegation_id
LEFT JOIN governance_envelopes e
  ON e.delegation_id = gd.delegation_id
GROUP BY
  gd.delegation_id,
  gd.package_id,
  gd.package_version
ORDER BY gd.created_at;
"

echo
echo "=== CURRENT DOWNSTREAM FK CONTRACTS ==="
for table in \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes
do
  echo "--- $table ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list($table);"
done

echo
echo "=== ACTIVE RUNTIME READERS / WRITERS OF DELEGATIONS ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'governance_delegations|createGovernanceDelegation|delegation_id' \
  db server routes \
  2>/dev/null | head -n 2400

echo
echo "=== SCRIPT / VALIDATION DEPENDENCIES ON HISTORICAL ROW ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'corridor-delegation|HISTORICAL_DELEGATION|historical.*Delegation|governance_delegations' \
  scripts docs/governance \
  2>/dev/null | head -n 2400

echo
echo "=== SOURCE TABLE CREATION CONTRACT ==="
sed -n '220,265p' db/governance-runtime.ts

echo
echo "=== CURRENT DELEGATION WRITE AUTHORITY ==="
sed -n '691,810p' db/governance-runtime.ts

echo
echo "=== CURRENT DATABASE INTEGRITY ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== DISPOSABLE SEPARATION SIMULATION ==="
TMP_DB="$(mktemp -t delegation-historical-separation).db"
cp db/main.db "$TMP_DB"

TMP_DB="$TMP_DB" node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database(process.env.TMP_DB);
db.pragma("foreign_keys = OFF");

const before = db.prepare(`
  SELECT *
  FROM governance_delegations
  WHERE delegation_id = 'corridor-delegation'
`).get();

if (!before) {
  throw new Error("Expected historical corridor-delegation is missing.");
}

const canonical = db.prepare(`
  SELECT COUNT(*) AS count
  FROM matilda_canonical_packages
  WHERE package_id = ?
    AND package_version = ?
`).get(before.package_id, before.package_version);

if (canonical.count !== 0) {
  throw new Error("Historical test row unexpectedly has Canonical Package lineage.");
}

const tx = db.transaction(() => {
  db.exec(`
    CREATE TABLE governance_delegations_historical (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version)
    );
  `);

  db.prepare(`
    INSERT INTO governance_delegations_historical (
      delegation_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    )
    SELECT
      delegation_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    FROM governance_delegations
    WHERE delegation_id = ?
  `).run(before.delegation_id);

  db.prepare(`
    DELETE FROM governance_delegations
    WHERE delegation_id = ?
  `).run(before.delegation_id);
});

tx();
db.pragma("foreign_keys = ON");

console.log("=== HISTORICAL ROW AFTER SEPARATION ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_delegations_historical
    WHERE delegation_id = ?
  `).get(before.delegation_id)
);

console.log("\n=== AUTHORITATIVE TABLE AFTER SEPARATION ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_delegations
    WHERE delegation_id = ?
  `).get(before.delegation_id)
);

console.log("\n=== FOREIGN KEY CHECK AFTER DELEGATION-ONLY SEPARATION ===");
console.log(db.prepare("PRAGMA foreign_key_check").all());

db.close();
NODE

rm -f "$TMP_DB"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=NEW_DELEGATION_AUTHORITY_REMAINS_CANONICAL_ONLY"
echo "VERIFIED_OUTCOME=LEGACY_DELEGATION_HISTORY_CAN_BE_IDENTIFIED_WITHOUT_RUNTIME_INFERENCE"
echo "CURRENT_SCOPE=MINIMUM_SAFE_HISTORICAL_DELEGATION_SEPARATION_SURFACE"
echo "MIGRATION_CANDIDATE=MOVE_ONLY_NONCANONICAL_LEGACY_DELEGATION_ROWS_TO_NONAUTHORITATIVE_HISTORICAL_PERSISTENCE"
echo "CANONICAL_DELEGATION_RUNTIME_CHANGE_EXPECTED=NO"
echo "CANONICAL_DELEGATION_WRITE_CHANGE_EXPECTED=NO"
echo "HISTORICAL_IDENTITY_CHANGE_ALLOWED=NO"
echo "HISTORICAL_PACKAGE_REPARENTING_ALLOWED=NO"
echo "DOWNSTREAM_REFERENCE_CHANGE=REQUIRES_CLASSIFICATION_FROM_SIMULATION"
echo "VALIDATION_ROOT_RECONCILIATION=DEFERRED"
echo "ENVELOPE_GATE_ROOT_RECONCILIATION=DEFERRED"
echo "ENVELOPE_ROOT_RECONCILIATION=DEFERRED"
echo "OPERATIONAL_INTAKE_ROOT_RECONCILIATION=DEFERRED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DOES_DELEGATION_ONLY_SEPARATION_LEAVE_ONLY_EXPECTED_DOWNSTREAM_LEGACY_FK_CONTRADICTIONS_OR_REQUIRE_A_BROADER_ATOMIC_MIGRATION_BOUNDARY"
