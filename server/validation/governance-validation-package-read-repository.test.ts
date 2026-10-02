import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import {
  loadExactGovernanceValidationPackage,
} from "./governance-validation-package-read-repository.ts";

function createDatabase(): Database.Database {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      requested_outcome TEXT,
      scope TEXT,
      constraints TEXT,
      success_criteria TEXT,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  return db;
}

test("loads exact Governance Validation package semantics", () => {
  const db = createDatabase();

  db.prepare(`
    INSERT INTO governance_packages (
      project_id,
      package_id,
      package_version,
      requested_outcome,
      scope,
      constraints,
      success_criteria
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    "hq",
    "pkg-1",
    1,
    "Deliver the approved outcome.",
    "Only the approved scope.",
    "Preserve governance boundaries.",
    "Approved outcome is complete.",
  );

  const result = loadExactGovernanceValidationPackage(db, {
    project_id: "hq",
    package_id: "pkg-1",
    package_version: 1,
  });

  assert.deepEqual(result, {
    project_id: "hq",
    package_id: "pkg-1",
    package_version: 1,
    requested_outcome: "Deliver the approved outcome.",
    scope: "Only the approved scope.",
    constraints: "Preserve governance boundaries.",
    success_criteria: "Approved outcome is complete.",
  });

  db.close();
});

test("fails closed when exact package identity is missing", () => {
  const db = createDatabase();

  assert.throws(
    () =>
      loadExactGovernanceValidationPackage(db, {
        project_id: "hq",
        package_id: "missing",
        package_version: 1,
      }),
    /not found or ambiguous/i,
  );

  db.close();
});

test("does not substitute another project/package/version", () => {
  const db = createDatabase();

  db.prepare(`
    INSERT INTO governance_packages (
      project_id,
      package_id,
      package_version,
      requested_outcome,
      scope,
      constraints,
      success_criteria
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    "other-project",
    "pkg-1",
    1,
    "Other outcome.",
    "Other scope.",
    "Other constraints.",
    "Other success criteria.",
  );

  assert.throws(
    () =>
      loadExactGovernanceValidationPackage(db, {
        project_id: "hq",
        package_id: "pkg-1",
        package_version: 1,
      }),
    /not found or ambiguous/i,
  );

  db.close();
});
