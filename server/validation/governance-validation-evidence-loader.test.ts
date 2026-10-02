import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import {
  loadGovernanceValidationEvidence,
} from "./governance-validation-evidence-loader.ts";

function createFixture() {
  const directory = mkdtempSync(join(tmpdir(), "governance-validation-evidence-"));
  const databasePath = join(directory, "main.db");
  const db = new Database(databasePath);

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
    "Deliver approved outcome.",
    "Approved scope.",
    "Preserve governance boundaries.",
    "Approved success criteria.",
  );

  db.close();

  return {
    databasePath,
    cleanup: () => rmSync(directory, { recursive: true, force: true }),
  };
}

test("loads semantic evidence using project identity recovered from exact AUTHORIZED Delegation", () => {
  const fixture = createFixture();

  try {
    const evidence = loadGovernanceValidationEvidence(
      {
        delegation_id: "delegation-1",
        package_id: "pkg-1",
        package_version: 1,
      },
      {
        database_path: fixture.databasePath,
        load_exact_governance_delegation: (identity) => ({
          delegation_id: identity.delegation_id,
          project_id: "hq",
          package_id: identity.package_id,
          package_version: identity.package_version,
          authorization_state: "AUTHORIZED",
        }),
      },
    );

    assert.equal(evidence.delegation.project_id, "hq");
    assert.equal(evidence.package.project_id, "hq");
    assert.equal(evidence.package.requested_outcome, "Deliver approved outcome.");
    assert.equal(evidence.package.success_criteria, "Approved success criteria.");
  } finally {
    fixture.cleanup();
  }
});

test("fails closed before semantic package loading for non-AUTHORIZED Delegation", () => {
  const fixture = createFixture();

  try {
    assert.throws(
      () =>
        loadGovernanceValidationEvidence(
          {
            delegation_id: "delegation-1",
            package_id: "pkg-1",
            package_version: 1,
          },
          {
            database_path: fixture.databasePath,
            load_exact_governance_delegation: (identity) => ({
              delegation_id: identity.delegation_id,
              project_id: "hq",
              package_id: identity.package_id,
              package_version: identity.package_version,
              authorization_state: "PENDING",
            }),
          },
        ),
      /Delegation is not authorized/i,
    );
  } finally {
    fixture.cleanup();
  }
});

test("fails closed when Delegation project identity does not resolve the exact package", () => {
  const fixture = createFixture();

  try {
    assert.throws(
      () =>
        loadGovernanceValidationEvidence(
          {
            delegation_id: "delegation-1",
            package_id: "pkg-1",
            package_version: 1,
          },
          {
            database_path: fixture.databasePath,
            load_exact_governance_delegation: (identity) => ({
              delegation_id: identity.delegation_id,
              project_id: "wrong-project",
              package_id: identity.package_id,
              package_version: identity.package_version,
              authorization_state: "AUTHORIZED",
            }),
          },
        ),
      /not found or ambiguous/i,
    );
  } finally {
    fixture.cleanup();
  }
});
