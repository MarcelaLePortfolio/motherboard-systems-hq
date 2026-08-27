import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { loadGovernanceExecutionReadChain } from "./governance-execution-read-repository";

function createDb() {
  const db = new Database(":memory:");
  db.exec(`
    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY, project_id TEXT NOT NULL,
      package_id TEXT NOT NULL, package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL, authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY, package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL, delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL, governance_findings TEXT,
      operational_requirements TEXT, capability_requirements TEXT,
      escalations TEXT, validation_timestamp TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY, package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL, delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL, gate_status TEXT NOT NULL,
      gate_reason TEXT, gate_decision_timestamp TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY, package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL, delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL, envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL, required_capabilities TEXT,
      operational_corridor TEXT, lifecycle_state TEXT NOT NULL, created_at TEXT NOT NULL
    );
  `);
  return db;
}

function seed(
  db: Database.Database,
  delegationStatus = "AUTHORIZED",
  validationStatus = "VALIDATION_PASSED",
  gateStatus = "OPEN",
) {
  const t = "2026-08-27T22:40:00.000Z";
  db.prepare("INSERT INTO governance_delegations VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    .run("d1", "hq", "p1", 1, delegationStatus, t, "marcela", t);
  db.prepare("INSERT INTO governance_validation_results VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("v1", "p1", 1, "d1", validationStatus, null, null, null, null, t, t);
  db.prepare("INSERT INTO governance_envelope_gates VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("g1", "p1", 1, "d1", "v1", gateStatus, null, t, t);
  db.prepare("INSERT INTO governance_envelopes VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("e1", "p1", 1, "d1", "v1", "g1", validationStatus,
      "governed_git_commit", "self_improvement_execution_activation", "ready", t);
}

const identity = {
  envelope_id: "e1",
  package_id: "p1",
  package_version: 1,
  delegation_id: "d1",
  validation_result_id: "v1",
  envelope_gate_id: "g1",
};

test("reads exact authorized correlated governance chain", () => {
  const db = createDb();
  seed(db);
  assert.equal(loadGovernanceExecutionReadChain(db, identity).governance.ok, true);
});

test("rejects unauthorized delegation", () => {
  const db = createDb();
  seed(db, "PENDING");
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /not authorized/);
});

test("rejects failed validation", () => {
  const db = createDb();
  seed(db, "AUTHORIZED", "VALIDATION_FAILED");
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /has not passed/);
});

test("rejects closed gate", () => {
  const db = createDb();
  seed(db, "AUTHORIZED", "VALIDATION_PASSED", "CLOSED");
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /not open/);
});

test("rejects lineage mismatch", () => {
  const db = createDb();
  seed(db);
  assert.throws(
    () => loadGovernanceExecutionReadChain(db, { ...identity, delegation_id: "wrong" }),
    /not found or ambiguous/,
  );
});

test("rejects missing artifact", () => {
  const db = createDb();
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /not found or ambiguous/);
});
