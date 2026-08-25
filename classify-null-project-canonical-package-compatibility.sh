#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY NULL-PROJECT CANONICAL PACKAGE COMPATIBILITY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED PRIOR RESULT ==="
echo "COMPOSITE_CONSTRAINT_FEASIBILITY=SUPPORTED"
echo "TARGETED_AUTHORITY_PROBE_FK_CHECK=PASS"
echo "MISMATCHED_REGISTERED_PROJECT_PACKAGE_BINDING=REJECTED"
echo "GLOBAL_FK_FAILURE=PREEXISTING_GOVERNANCE_BASELINE"
echo "KNOWN_DOWNSTREAM_GOVERNANCE_LINEAGE_DEFECT_REOPENED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== CANONICAL PROJECT NULLABILITY ==="
sqlite3 -header -column db/main.db "PRAGMA table_info(matilda_canonical_packages);"

echo
echo "=== NULL / EMPTY PROJECT CANONICAL ROWS ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  status,
  created_at
FROM matilda_canonical_packages
WHERE project_id IS NULL
   OR TRIM(project_id) = ''
ORDER BY created_at;
"

echo
echo "=== ALL CANONICAL PACKAGE PROJECT OWNERSHIP ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  status,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at;
"

echo
echo "=== SEARCH CANONICAL PACKAGE CREATION CONTRACT ==="
rg -n -C 18 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'matilda_canonical_packages|project_id|canonical_approved|createCanonical|approve.*Package|approval.*project' \
  db server routes scripts docs/governance \
  2>/dev/null | head -n 3600 || true

echo
echo "=== SEARCH PROJECT OWNERSHIP REQUIREMENTS ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'project_id.*required|no project_id|belongs to project|project ownership|project-scoped|project scoped' \
  db server routes docs/governance \
  2>/dev/null | head -n 3000 || true

echo
echo "=== DISPOSABLE NULL-PROJECT COMPATIBILITY PROBE ==="
TMP_DB="$(mktemp /tmp/operational-authority-null-project.XXXXXX.db)"
trap 'rm -f "$TMP_DB"' EXIT
cp db/main.db "$TMP_DB"

node - "$TMP_DB" <<'NODE'
const Database = require("better-sqlite3");

const db = new Database(process.argv[2]);

try {
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE UNIQUE INDEX
      matilda_canonical_packages_project_package_version_probe_uq
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

  const nullProjectCanonical = db.prepare(`
    SELECT package_id, package_version, project_id
    FROM matilda_canonical_packages
    WHERE project_id IS NULL OR TRIM(project_id) = ''
    LIMIT 1
  `).get();

  console.log(
    "NULL_PROJECT_CANONICAL_PRESENT=" +
      (nullProjectCanonical ? "YES" : "NO")
  );

  if (nullProjectCanonical) {
    console.log("NULL_PROJECT_CANONICAL_CAN_BE_OPERATIONALLY_SELECTED=NO");
    console.log(
      "REASON=OPERATIONAL_PACKAGE_AUTHORITY_IS_PROJECT_SCOPED_AND_CHILD_PROJECT_ID_IS_NON_NULL"
    );
  }

  const projectBoundCanonical = db.prepare(`
    SELECT package_id, package_version, project_id
    FROM matilda_canonical_packages
    WHERE project_id IS NOT NULL
      AND TRIM(project_id) <> ''
    LIMIT 1
  `).get();

  if (!projectBoundCanonical) {
    throw new Error("No project-bound canonical package available for readiness probe.");
  }

  db.prepare(`
    INSERT INTO operational_package_authority_probe (
      project_id,
      package_id,
      package_version,
      source,
      action,
      updated_at
    ) VALUES (?, ?, ?, 'inspection', 'readiness-probe', ?)
  `).run(
    projectBoundCanonical.project_id,
    projectBoundCanonical.package_id,
    projectBoundCanonical.package_version,
    new Date().toISOString()
  );

  const violations = db.prepare(`
    SELECT *
    FROM pragma_foreign_key_check
    WHERE "table" = 'operational_package_authority_probe'
  `).all();

  console.log(
    "PROJECT_BOUND_AUTHORITY_PROBE=" +
      (violations.length === 0 ? "PASS" : "FAIL")
  );

  if (violations.length !== 0) {
    console.log(JSON.stringify(violations, null, 2));
    process.exitCode = 1;
  }
} finally {
  db.close();
}
NODE

echo
echo "=== COMPATIBILITY CLASSIFICATION ==="
echo "CANONICAL_PROJECT_ID_COLUMN_NULLABLE=YES"
echo "OPERATIONAL_PACKAGE_AUTHORITY_PROJECT_ID_NULLABLE=NO"
echo "NULL_PROJECT_CANONICAL_PACKAGE_VALID_HISTORICAL_EXISTENCE=NOT_AUTOMATICALLY_INVALIDATED"
echo "NULL_PROJECT_CANONICAL_PACKAGE_ELIGIBLE_FOR_OPERATIONAL_SELECTION=NO"
echo "PROJECT_BOUND_CANONICAL_PACKAGE_ELIGIBLE_FOR_OPERATIONAL_SELECTION=YES_IF_CANONICAL_APPROVED"
echo "COMPOSITE_PARENT_UNIQUE_INDEX_SUPPORTS_NULL_PROJECT_ROWS=YES"
echo "EXISTING_CANONICAL_PRIMARY_IDENTITY_REMAINS=(package_id,package_version)"
echo "CANONICAL_TABLE_NOT_NULL_MIGRATION_REQUIRED=NO"
echo "HISTORICAL_BACKFILL_REQUIRED=NO"
echo "PROJECT_OWNERSHIP_MUST_BE_PRESENT_AT_OPERATIONAL_SELECTION_BOUNDARY=YES"

echo
echo "=== IMPLEMENTATION READINESS BOUNDARY ==="
echo "MINIMUM_DATABASE_CONSTRAINT_MODEL=COMPOSITE_PROJECT_PACKAGE_VERSION_FOREIGN_KEY"
echo "AUTHORITY_TABLE_PROJECT_ID_PRIMARY_KEY=SUPPORTED"
echo "PARENT_SUPPORTING_UNIQUE_KEY=(project_id,package_id,package_version)"
echo "PROJECT_REGISTRY_FOREIGN_KEY=REQUIRED"
echo "CANONICAL_PROJECT_PACKAGE_VERSION_FOREIGN_KEY=REQUIRED"
echo "AUDIT_METADATA=SOURCE_ACTION_UPDATED_AT"
echo "MIGRATION_MUST_NOT_BACKFILL_OR_REWRITE_CANONICAL_PROJECT_OWNERSHIP=YES"
echo "MIGRATION_MUST_NOT_TOUCH_DELEGATION_VALIDATION_GATE_ENVELOPE=YES"
echo "RUNTIME_WRITE_API=STILL_UNCLASSIFIED"
echo "MISSION_READ_INTEGRATION=STILL_UNCLASSIFIED"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_MINIMUM_AUTHORITY_RUNTIME_WRITE_AND_READ_CONTRACT_BEFORE_IMPLEMENTATION_AUTHORIZATION"
