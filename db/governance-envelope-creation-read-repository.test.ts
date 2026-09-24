import Database from "better-sqlite3";
import test from "node:test";
import assert from "node:assert/strict";

import {
  loadExactGovernanceEnvelopeCreationReadChain,
} from "./governance-envelope-creation-read-repository.js";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_validation_results (
      validation_result_id TEXT,
      package_id TEXT,
      package_version INTEGER,
      delegation_id TEXT,
      validation_status TEXT,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT,
      created_at TEXT
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT,
      package_id TEXT,
      package_version INTEGER,
      delegation_id TEXT,
      validation_result_id TEXT,
      gate_status TEXT,
      gate_reason TEXT,
      gate_decision_timestamp TEXT,
      created_at TEXT
    );
  `);

  return db;
}

function seedExactChain(db: Database.Database) {
  db.prepare(`
    INSERT INTO governance_validation_results VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    "validation-1",
    "package-1",
    1,
    "delegation-1",
    "VALIDATION_PASSED",
    null,
    " planning_only ",
    " engineering_planning ",
    null,
    "2026-09-24T00:00:00.000Z",
    "2026-09-24T00:00:00.000Z",
  );

  db.prepare(`
    INSERT INTO governance_envelope_gates VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    "gate-1",
    "package-1",
    1,
    "delegation-1",
    "validation-1",
    "OPEN",
    null,
    "2026-09-24T00:01:00.000Z",
    "2026-09-24T00:01:00.000Z",
  );
}

test("loads exact correlated Validation and Envelope Gate lineage", () => {
  const db = createDb();
  seedExactChain(db);

  const result = loadExactGovernanceEnvelopeCreationReadChain(db, {
    validation_result_id: "validation-1",
    envelope_gate_id: "gate-1",
    delegation_id: "delegation-1",
    package_id: "package-1",
    package_version: 1,
  });

  assert.equal(result.validation_result.validation_status, "VALIDATION_PASSED");
  assert.equal(result.envelope_gate.gate_status, "OPEN");
  db.close();
});

test("fails closed on wrong Gate lineage", () => {
  const db = createDb();
  seedExactChain(db);

  assert.throws(() =>
    loadExactGovernanceEnvelopeCreationReadChain(db, {
      validation_result_id: "validation-1",
      envelope_gate_id: "wrong-gate",
      delegation_id: "delegation-1",
      package_id: "package-1",
      package_version: 1,
    }),
  );

  db.close();
});

test("fails closed on wrong Validation lineage", () => {
  const db = createDb();
  seedExactChain(db);

  assert.throws(() =>
    loadExactGovernanceEnvelopeCreationReadChain(db, {
      validation_result_id: "wrong-validation",
      envelope_gate_id: "gate-1",
      delegation_id: "delegation-1",
      package_id: "package-1",
      package_version: 1,
    }),
  );

  db.close();
});
