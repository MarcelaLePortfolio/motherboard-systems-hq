import assert from "node:assert/strict";
import test from "node:test";

import Database from "better-sqlite3";

import { repairStaleGovernanceDelegationForeignKeys } from "./governance-stale-delegation-fk-migration";

function foreignKeyParents(
  db: Database.Database,
  table: string,
): string[] {
  return (
    db.prepare(`PRAGMA foreign_key_list("${table}")`).all() as Array<{
      table: string;
    }>
  ).map((row) => row.table);
}

test("repairs stale Delegation FK targets without rewriting downstream lifecycle lineage", () => {
  const db = new Database(":memory:");

  db.pragma("foreign_keys = OFF");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY
    );

    CREATE TABLE governance_delegations_legacy_root (
      delegation_id TEXT PRIMARY KEY
    );

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
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations_legacy_root(delegation_id)
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations_legacy_root(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id)
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations_legacy_root(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates(envelope_gate_id)
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL,
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id)
    );

    INSERT INTO governance_packages VALUES ('corridor-smoke', 1);
    INSERT INTO governance_delegations VALUES ('corridor-delegation');

    INSERT INTO governance_validation_results VALUES (
      'corridor-validation',
      'corridor-smoke',
      1,
      'corridor-delegation',
      'VALIDATION_PASSED',
      NULL,
      NULL,
      NULL,
      NULL,
      '2026-07-29T04:10:30.000Z',
      '2026-07-29T04:10:30.000Z'
    );

    INSERT INTO governance_envelope_gates VALUES (
      'corridor-gate',
      'corridor-smoke',
      1,
      'corridor-delegation',
      'corridor-validation',
      'PASSED',
      NULL,
      '2026-07-29T04:20:30.000Z',
      '2026-07-29T04:20:30.000Z'
    );

    INSERT INTO governance_envelopes VALUES (
      'corridor-envelope',
      'corridor-smoke',
      1,
      'corridor-delegation',
      'corridor-validation',
      'corridor-gate',
      'VALIDATION_PASSED',
      NULL,
      NULL,
      'ENVELOPE_CREATED',
      '2026-07-29T04:30:30.000Z'
    );

    INSERT INTO governance_envelopes VALUES (
      'demo-env-1',
      'corridor-smoke',
      1,
      'missing-demo-delegation',
      'missing-demo-validation',
      'missing-demo-gate',
      'PENDING',
      NULL,
      NULL,
      'ENVELOPE_CREATED',
      '2026-07-28T21:36:59.000Z'
    );

    INSERT INTO governance_lifecycle_events (
      envelope_id,
      transition_authorization,
      persisted_at
    ) VALUES (
      'corridor-envelope',
      'MISSION_COMPLETED',
      '2026-07-29T04:30:30.000Z'
    );

    INSERT INTO governance_lifecycle_events (
      envelope_id,
      transition_authorization,
      persisted_at
    ) VALUES (
      'demo-env-1',
      'ENVELOPE_CREATED',
      '2026-07-29T00:36:09.000Z'
    );

    DROP TABLE governance_delegations_legacy_root;
  `);

  db.pragma("foreign_keys = ON");

  assert.equal(repairStaleGovernanceDelegationForeignKeys(db), true);

  for (const table of [
    "governance_validation_results",
    "governance_envelope_gates",
    "governance_envelopes",
  ]) {
    const parents = foreignKeyParents(db, table);

    assert.equal(
      parents.includes("governance_delegations_legacy_root"),
      false,
    );

    assert.equal(
      parents.includes("governance_delegations"),
      true,
    );
  }

  assert.deepEqual(
    foreignKeyParents(db, "governance_lifecycle_events"),
    ["governance_envelopes"],
  );

  assert.deepEqual(
    db
      .prepare(`
        SELECT envelope_id
        FROM governance_envelopes
        ORDER BY envelope_id
      `)
      .all(),
    [
      { envelope_id: "corridor-envelope" },
      { envelope_id: "demo-env-1" },
    ],
  );

  assert.deepEqual(
    db
      .prepare(`
        SELECT envelope_id, transition_authorization
        FROM governance_lifecycle_events
        ORDER BY event_id
      `)
      .all(),
    [
      {
        envelope_id: "corridor-envelope",
        transition_authorization: "MISSION_COMPLETED",
      },
      {
        envelope_id: "demo-env-1",
        transition_authorization: "ENVELOPE_CREATED",
      },
    ],
  );

  assert.equal(
    repairStaleGovernanceDelegationForeignKeys(db),
    false,
  );

  db.close();
});
