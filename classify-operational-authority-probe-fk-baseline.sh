#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY OPERATIONAL AUTHORITY PROBE FK BASELINE ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== OBSERVED PROBE RESULT ==="
echo "COMPOSITE_VALID_BINDING=ACCEPTED"
echo "COMPOSITE_MISMATCHED_REGISTERED_PROJECT_BINDING=REJECTED"
echo "COMPOSITE_PROJECT_PACKAGE_OWNERSHIP_ENFORCEMENT=SUPPORTED_BY_PROBE"
echo "GLOBAL_FOREIGN_KEY_CHECK=FAIL"

echo
echo "=== CLASSIFY GLOBAL FK FAILURE ==="
echo "QUESTION=DID_COMPOSITE_AUTHORITY_PROBE_INTRODUCE_THE_REPORTED_FOREIGN_KEY_VIOLATIONS"
echo "ANSWER=NOT_ESTABLISHED"
echo "REASON=REPORTED_VIOLATIONS_REFERENCE_PREEXISTING_GOVERNANCE_TABLES_AND_KNOWN_STALE_DOWNSTREAM_LINEAGE"
echo "REASON=NO_REPORTED_VIOLATION_REFERENCES_OPERATIONAL_PACKAGE_AUTHORITY_PROBE"
echo "REASON=NO_REPORTED_VIOLATION_REFERENCES_NEW_COMPOSITE_CANONICAL_PACKAGE_INDEX"

echo
echo "=== LIVE DATABASE FOREIGN KEY BASELINE ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== TARGETED LIVE GOVERNANCE FK BASELINE ==="
sqlite3 -header -column db/main.db "
SELECT *
FROM pragma_foreign_key_check
WHERE \"table\" IN (
  'governance_delegations',
  'governance_validation_results',
  'governance_envelope_gates',
  'governance_envelopes'
)
ORDER BY \"table\", rowid, fkid;
"

echo
echo "=== TARGETED DISPOSABLE PROBE ==="
TMP_DB="$(mktemp /tmp/operational-authority-targeted-fk.XXXXXX.db)"
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

  const canonical = db.prepare(`
    SELECT package_id, package_version, project_id
    FROM matilda_canonical_packages
    WHERE project_id IS NOT NULL
    ORDER BY created_at
    LIMIT 1
  `).get();

  if (!canonical) {
    throw new Error("No project-bound canonical package available.");
  }

  db.prepare(`
    INSERT INTO operational_package_authority_probe (
      project_id,
      package_id,
      package_version,
      source,
      action,
      updated_at
    ) VALUES (?, ?, ?, 'inspection', 'valid-binding', ?)
  `).run(
    canonical.project_id,
    canonical.package_id,
    canonical.package_version,
    new Date().toISOString()
  );

  const probeFkViolations = db.prepare(`
    SELECT *
    FROM pragma_foreign_key_check
    WHERE "table" = 'operational_package_authority_probe'
  `).all();

  console.log(
    "TARGETED_AUTHORITY_PROBE_FK_CHECK=" +
      (probeFkViolations.length === 0 ? "PASS" : "FAIL")
  );

  if (probeFkViolations.length !== 0) {
    console.log(JSON.stringify(probeFkViolations, null, 2));
    process.exitCode = 1;
  }

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
        project_id,
        package_id,
        package_version,
        source,
        action,
        updated_at
      ) VALUES (?, ?, ?, 'inspection', 'mismatch-binding', ?)
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
      "Composite FK accepted a package belonging to another registered project."
    );
  }

  console.log("COMPOSITE_CONSTRAINT_PROBE=PASS");
} finally {
  db.close();
}
NODE

echo
echo "=== CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "COMPOSITE_CONSTRAINT_FEASIBILITY=SUPPORTED"
echo "TARGETED_PROBE_INTEGRITY=REQUIRED_TO_PASS"
echo "GLOBAL_FK_FAILURE=PREEXISTING_BASELINE_UNLESS_LIVE_CHECK_FALSIFIES"
echo "KNOWN_DOWNSTREAM_GOVERNANCE_LINEAGE_DEFECT_REOPENED=NO"
echo "OPERATIONAL_AUTHORITY_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=IF_TARGETED_PROBE_PASSES_AND_LIVE_FK_CHECK_MATCHES_PREEXISTING_GOVERNANCE_DEFECTS_CLASSIFY_NULL_PROJECT_CANONICAL_PACKAGE_COMPATIBILITY"
