import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  loadExactGovernanceEnvelopeGateValidationResult,
} from "./governance-envelope-gate-validation-read-repository";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_validation_results (
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
      created_at TEXT NOT NULL
    )
  `);

  return db;
}

function seed(
  db: Database.Database,
  overrides: Partial<{
    validation_result_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_status: string;
  }> = {},
) {
  const row = {
    validation_result_id: "validation-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_status: "VALIDATION_PASSED",
    ...overrides,
  };

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
    row.validation_result_id,
    row.package_id,
    row.package_version,
    row.delegation_id,
    row.validation_status,
    "2026-09-23T20:00:00.000Z",
    "2026-09-23T20:00:00.000Z",
  );

  return row;
}

const identity = {
  validation_result_id: "validation-1",
  delegation_id: "delegation-1",
  package_id: "package-1",
  package_version: 1,
};

test("loads exactly one correlated Validation result", () => {
  const db = createDb();
  seed(db);

  const result = loadExactGovernanceEnvelopeGateValidationResult(db, identity);

  assert.equal(result.validation_result_id, identity.validation_result_id);
  assert.equal(result.delegation_id, identity.delegation_id);
  assert.equal(result.package_id, identity.package_id);
  assert.equal(result.package_version, identity.package_version);
  assert.equal(result.validation_status, "VALIDATION_PASSED");
});

test("fails closed when Validation result is missing", () => {
  const db = createDb();

  assert.throws(
    () => loadExactGovernanceEnvelopeGateValidationResult(db, identity),
    /not found or ambiguous/,
  );
});

test("fails closed on wrong package", () => {
  const db = createDb();
  seed(db);

  assert.throws(
    () =>
      loadExactGovernanceEnvelopeGateValidationResult(db, {
        ...identity,
        package_id: "wrong-package",
      }),
    /not found or ambiguous/,
  );
});

test("fails closed on wrong package version", () => {
  const db = createDb();
  seed(db);

  assert.throws(
    () =>
      loadExactGovernanceEnvelopeGateValidationResult(db, {
        ...identity,
        package_version: 2,
      }),
    /not found or ambiguous/,
  );
});

test("fails closed on wrong delegation", () => {
  const db = createDb();
  seed(db);

  assert.throws(
    () =>
      loadExactGovernanceEnvelopeGateValidationResult(db, {
        ...identity,
        delegation_id: "wrong-delegation",
      }),
    /not found or ambiguous/,
  );
});
