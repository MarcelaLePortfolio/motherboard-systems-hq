#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION CANONICAL WRITE / LEGACY READ COEXISTENCE BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED EVIDENCE ==="
echo "CORRIDOR_SMOKE_GOVERNANCE_AUTHORITY=HISTORICAL"
echo "CORRIDOR_SMOKE_CURRENT_READ_DEPENDENCY=ACTIVE"
echo "CORRIDOR_SMOKE_REPARENTING_ALLOWED=NO"
echo "CORRIDOR_SMOKE_DELETION_ALLOWED=NO"
echo "VALIDATION_TABLE_RUNTIME_ACTIVE=YES"
echo "CURRENT_VALIDATION_PACKAGE_ROOT=GOVERNANCE_PACKAGES"
echo "CURRENT_VALIDATION_DELEGATION_FK=STALE_GOVERNANCE_DELEGATIONS_LEGACY_ROOT"
echo "NEW_DELEGATION_AUTHORITY_ROOT=MATILDA_CANONICAL_PACKAGES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT VALIDATION TABLE CONTRACT ==="
sqlite3 db/main.db ".schema governance_validation_results"
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_validation_results);"

echo
echo "=== SOURCE VALIDATION TABLE CONTRACT ==="
sed -n '245,262p' db/governance-runtime.ts

echo
echo "=== CURRENT VALIDATION WRITE PATH ==="
sed -n '811,930p' db/governance-runtime.ts

echo
echo "=== VALIDATION LINEAGE REQUIREMENTS ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'Validation.*Package|Validation.*Delegation|validation.*package_id|validation.*package_version|validation.*delegation_id|delegation.*validation|package.*validation|exact.*lineage|lineage.*validation' \
  docs/governance db server scripts \
  2>/dev/null | head -n 2400

echo
echo "=== CURRENT PACKAGE ROOTS ==="
sqlite3 -header -column db/main.db "
SELECT
  'legacy' AS root_class,
  package_id,
  package_version
FROM governance_packages
UNION ALL
SELECT
  'canonical',
  package_id,
  package_version
FROM matilda_canonical_packages
ORDER BY package_id, package_version, root_class;
"

echo
echo "=== CURRENT DELEGATIONS BY ROOT ==="
sqlite3 -header -column db/main.db "
SELECT
  gd.delegation_id,
  gd.package_id,
  gd.package_version,
  gd.authorization_state,
  CASE
    WHEN cp.package_id IS NOT NULL THEN 'CANONICAL'
    WHEN gp.package_id IS NOT NULL THEN 'LEGACY_HISTORICAL'
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
echo "=== CURRENT VALIDATION ROWS ==="
sqlite3 -header -column db/main.db "
SELECT
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status,
  created_at
FROM governance_validation_results
ORDER BY created_at;
"

echo
echo "=== MISSION READ DEPENDENCY ==="
sed -n '18,75p' db/mission-read-repository.ts

echo
echo "=== READ-COMPATIBILITY PRECEDENT SEARCH ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE VIEW|UNION ALL.*historical|historical.*UNION ALL|compatibility view|read compatibility|legacy.*view|canonical.*view|legacy.*read|read.*legacy|write.*canonical|canonical.*write' \
  db drizzle server scripts docs \
  2>/dev/null | head -n 2200

echo
echo "=== DISPOSABLE CANONICAL WRITE TEST ==="
TMP_DB="$(mktemp -t validation-coexistence).db"
cp db/main.db "$TMP_DB"

TMP_DB="$TMP_DB" node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database(process.env.TMP_DB);
db.pragma("foreign_keys = ON");

const canonical = db.prepare(`
  SELECT
    cp.package_id,
    cp.package_version,
    gd.delegation_id
  FROM matilda_canonical_packages cp
  JOIN governance_delegations gd
    ON gd.package_id = cp.package_id
   AND gd.package_version = cp.package_version
  ORDER BY gd.created_at DESC
  LIMIT 1
`).get();

console.log("=== CANONICAL PACKAGE + DELEGATION CANDIDATE ===");
console.log(canonical ?? null);

if (!canonical) {
  console.log("CANONICAL_VALIDATION_INSERT_TEST=SKIPPED_NO_CANONICAL_DELEGATION");
  db.close();
  process.exit(0);
}

const now = new Date().toISOString();
const id = `validation-coexistence-${Date.now()}`;

try {
  db.prepare(`
    INSERT INTO governance_validation_results (
      validation_result_id,
      package_id,
      package_version,
      delegation_id,
      validation_status,
      governance_findings,
      operational_requirements,
      capability_requirements,
      escalations,
      validation_timestamp,
      created_at
    ) VALUES (?, ?, ?, ?, ?, NULL, NULL, NULL, NULL, ?, ?)
  `).run(
    id,
    canonical.package_id,
    canonical.package_version,
    canonical.delegation_id,
    "VALIDATION_PASSED",
    now,
    now
  );

  console.log("CURRENT_TABLE_ACCEPTS_CANONICAL_VALIDATION=YES");
} catch (error) {
  console.log("CURRENT_TABLE_ACCEPTS_CANONICAL_VALIDATION=NO");
  console.log(
    "CURRENT_TABLE_CANONICAL_VALIDATION_ERROR=" +
      (error instanceof Error ? error.message : String(error))
  );
}

console.log("=== FOREIGN KEY CHECK ===");
console.log(db.prepare("PRAGMA foreign_key_check").all());

db.close();
NODE

rm -f "$TMP_DB"

echo
echo "=== CURRENT FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== SCOPE MAP ==="
echo "SOLVED=DELEGATION_NEW_WRITE_AUTHORITY_IS_CANONICAL_PACKAGE_ROOTED"
echo "STABILIZED=CORRIDOR_SMOKE_IS_HISTORICAL_AUTHORITY_BUT_ACTIVE_READ_DEPENDENCY"
echo "IMPLEMENTED=VALIDATION_RUNTIME_WRITE_SURFACE_EXISTS"
echo "PARTIALLY_IMPLEMENTED=CANONICAL_GOVERNANCE_LINEAGE_BEYOND_DELEGATION"
echo "DEFERRED=GATE_ENVELOPE_OPERATIONAL_INTAKE_ROOT_RECONCILIATION"
echo "ABSENT=VERIFIED_CANONICAL_VALIDATION_PERSISTENCE_PATH"
echo "CURRENT_SCOPE=VALIDATION_CANONICAL_WRITE_COEXISTENCE_BOUNDARY"
echo "OUT_OF_SCOPE=MISSION_CONTROL_ACTIVE_MISSION_BINDING"
echo "OUT_OF_SCOPE=GATE_ROOT_RECONCILIATION"
echo "OUT_OF_SCOPE=ENVELOPE_ROOT_RECONCILIATION"
echo "OUT_OF_SCOPE=OPERATIONAL_INTAKE_ROOT_RECONCILIATION"
echo "NEXT_CANONICAL_MILESTONE=VALIDATION_ROOT_RECONCILIATION"
echo "CORRIDOR_CLOSE_READY=NO"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=LEGACY_CORRIDOR_SMOKE_READ_LINEAGE_MUST_REMAIN_AVAILABLE"
echo "VERIFIED_OUTCOME=LEGACY_CORRIDOR_SMOKE_MUST_NOT_GAIN_CANONICAL_AUTHORITY"
echo "VERIFIED_OUTCOME=NEW_VALIDATION_MUST_FOLLOW_CANONICAL_PACKAGE_AND_DELEGATION_LINEAGE"
echo "ARCHITECTURAL_UNCERTAINTY=HOW_TO_PRESERVE_LEGACY_READ_LINEAGE_WHILE_DATABASE_ENFORCING_CANONICAL_VALIDATION_WRITES"
echo "IMPLEMENTATION_READINESS_UNCERTAINTY=MINIMUM_PERSISTENCE_AND_READ_COMPATIBILITY_SURFACE"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_FROM_THE_DISPOSABLE_WRITE_RESULT_AND_REPOSITORY_PRECEDENT_WHETHER_SEPARATE_CANONICAL_VALIDATION_PERSISTENCE_IS_REQUIRED"
