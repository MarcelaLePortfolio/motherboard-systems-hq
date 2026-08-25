#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT OPERATIONAL PACKAGE AUTHORITY DATABASE CONSTRAINT MODEL ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED OWNERSHIP ==="
echo "OWNERSHIP_MODEL=DEDICATED_PROJECT_SCOPED_AUTHORITY_BOUNDARY"
echo "MINIMUM_PERSISTED_IDENTITY=(project_id,package_id,package_version)"
echo "PRIMARY_AUTHORITY_KEY=PROJECT_ID"
echo "PACKAGE_REFERENCE_TARGET=MATILDA_CANONICAL_PACKAGES"
echo "PROJECT_REFERENCE_TARGET=PROJECT_REGISTRY"
echo "EXACT_PACKAGE_VERSION_REFERENCE_REQUIRED=YES"
echo "PROJECT_PACKAGE_OWNERSHIP_MATCH_REQUIRED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== CURRENT CANONICAL PACKAGE KEYS ==="
sqlite3 -header -column db/main.db "PRAGMA table_info(matilda_canonical_packages);"
sqlite3 -header -column db/main.db "PRAGMA index_list(matilda_canonical_packages);"

echo
echo "=== CURRENT CANONICAL PACKAGE INDEX DEFINITIONS ==="
sqlite3 -header -column db/main.db "
SELECT name, sql
FROM sqlite_master
WHERE type = 'index'
  AND tbl_name = 'matilda_canonical_packages'
ORDER BY name;
"

echo
echo "=== CURRENT PROJECT REGISTRY KEY ==="
sqlite3 -header -column db/main.db "PRAGMA table_info(project_registry);"

echo
echo "=== CURRENT PACKAGE DATA ==="
sqlite3 -header -column db/main.db "
SELECT package_id, package_version, project_id, status
FROM matilda_canonical_packages
ORDER BY package_id, package_version;
"

echo
echo "=== SEARCH COMPOSITE FOREIGN KEY PRECEDENTS ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FOREIGN KEY \([^)]*,[^)]*\)|REFERENCES [^(]+\([^)]*,[^)]*\)|UNIQUE \([^)]*,[^)]*\)' \
  db drizzle scripts docs/governance \
  2>/dev/null | head -n 3200 || true

echo
echo "=== SEARCH TRIGGER / OWNERSHIP ENFORCEMENT PRECEDENTS ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE TRIGGER|BEFORE INSERT|BEFORE UPDATE|RAISE\(|project_id.*package_id|package_id.*project_id' \
  db drizzle scripts \
  2>/dev/null | head -n 3200 || true

echo
echo "=== CONSTRAINT CANDIDATES ==="
echo "CANDIDATE_A=SEPARATE_PROJECT_FK_PLUS_EXISTING_PACKAGE_VERSION_FK"
echo "CANDIDATE_A_PROJECT_PACKAGE_MATCH_DATABASE_ENFORCED=NO"
echo "CANDIDATE_A_RESULT=INSUFFICIENT"
echo
echo "CANDIDATE_B=COMPOSITE_PROJECT_PACKAGE_VERSION_FOREIGN_KEY"
echo "CANDIDATE_B_CHILD_KEY=(project_id,package_id,package_version)"
echo "CANDIDATE_B_PARENT_KEY=(project_id,package_id,package_version)"
echo "CANDIDATE_B_EXACT_VERSION_DATABASE_ENFORCED=YES"
echo "CANDIDATE_B_PROJECT_PACKAGE_MATCH_DATABASE_ENFORCED=YES"
echo "CANDIDATE_B_REQUIRES_PARENT_UNIQUE_COMPOSITE_KEY=YES"
echo
echo "CANDIDATE_C=TRIGGER_ENFORCED_PROJECT_PACKAGE_MATCH"
echo "CANDIDATE_C_RESULT=POSSIBLE_BUT_MORE_COMPLEX"
echo
echo "CANDIDATE_D=APPLICATION_LAYER_PROJECT_PACKAGE_MATCH_ONLY"
echo "CANDIDATE_D_RESULT=REJECT"

echo
echo "=== DISPOSABLE SQLITE FEASIBILITY TEST ==="
TMP_DB="$(mktemp /tmp/operational-package-authority-constraint.XXXXXX.db)"
trap 'rm -f "$TMP_DB"' EXIT
cp db/main.db "$TMP_DB"

node - "$TMP_DB" <<'NODE'
const Database = require("better-sqlite3");

const path = process.argv[2];
const db = new Database(path);

try {
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE UNIQUE INDEX
      matilda_canonical_packages_project_package_version_uq
    ON matilda_canonical_packages (
      project_id,
      package_id,
      package_version
    );

    CREATE TABLE operational_package_authority_probe (
      project_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      source TEXT NOT NULL,
      action TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (project_id)
        REFERENCES project_registry(project_id),
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(
          project_id,
          package_id,
          package_version
        )
    );
  `);

  const canonical = db.prepare(`
    SELECT package_id, package_version, project_id
    FROM matilda_canonical_packages
    WHERE project_id IS NOT NULL
    ORDER BY created_at
    LIMIT 1
  `).get();

  if (!canonical) {
    throw new Error("No project-bound canonical package available for probe.");
  }

  db.prepare(`
    INSERT INTO operational_package_authority_probe (
      project_id, package_id, package_version, source, action, updated_at
    ) VALUES (?, ?, ?, 'inspection', 'select', ?)
  `).run(
    canonical.project_id,
    canonical.package_id,
    canonical.package_version,
    new Date().toISOString()
  );

  console.log("VALID_PROJECT_PACKAGE_VERSION_BINDING=ACCEPTED");

  const otherProject = "__operational_authority_probe_project__";

  db.prepare(`
    INSERT INTO project_registry (
      project_id,
      display_name,
      registration_status,
      availability_status,
      active_context_eligible,
      created_at,
      updated_at
    ) VALUES (?, ?, 'registered', 'available', 1, ?, ?)
  `).run(
    otherProject,
    "Operational Authority Probe",
    new Date().toISOString(),
    new Date().toISOString()
  );

  let mismatchRejected = false;

  try {
    db.prepare(`
      INSERT INTO operational_package_authority_probe (
        project_id, package_id, package_version, source, action, updated_at
      ) VALUES (?, ?, ?, 'inspection', 'mismatch-probe', ?)
    `).run(
      otherProject,
      canonical.package_id,
      canonical.package_version,
      new Date().toISOString()
    );
  } catch (error) {
    mismatchRejected = true;
    console.log("MISMATCHED_REGISTERED_PROJECT_PACKAGE_BINDING=REJECTED");
    console.log("MISMATCH_REJECTION=" + String(error.message));
  }

  if (!mismatchRejected) {
    throw new Error(
      "Composite authority probe accepted a canonical package owned by a different registered project."
    );
  }

  const fkCheck = db.prepare("PRAGMA foreign_key_check").all();
  console.log("FOREIGN_KEY_CHECK=" + (fkCheck.length === 0 ? "PASS" : "FAIL"));

  if (fkCheck.length !== 0) {
    console.log(JSON.stringify(fkCheck, null, 2));
    process.exitCode = 1;
  }
} finally {
  db.close();
}
NODE

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "PREFERRED_CONSTRAINT_MODEL=COMPOSITE_PROJECT_PACKAGE_VERSION_FOREIGN_KEY_IF_DISPOSABLE_TEST_PASSES"
echo "EXISTING_CANONICAL_PRIMARY_IDENTITY=(package_id,package_version)_REMAINS_UNCHANGED"
echo "ADDITIONAL_PARENT_UNIQUE_KEY=(project_id,package_id,package_version)_IS_INTEGRITY_SUPPORT_NOT_NEW_PACKAGE_IDENTITY"
echo "PROJECT_ID_NULLABILITY_ON_CANONICAL_PACKAGES_REQUIRES_SEPARATE_READINESS_CLASSIFICATION=YES"
echo "AUTHORITY_ROW_PROJECT_ID_PRIMARY_KEY=STILL_COHERENT"
echo "AUDIT_FIELDS=SOURCE_ACTION_UPDATED_AT_MINIMUM_PRECEDENT"
echo "RUNTIME_WRITE_API=NOT_YET_DESIGNED"
echo "MISSION_READ_INTEGRATION=NOT_YET_DESIGNED"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_NULL_PROJECT_CANONICAL_PACKAGE_COMPATIBILITY_AND_IMPLEMENTATION_READINESS_FOR_COMPOSITE_CONSTRAINT_MODEL"
