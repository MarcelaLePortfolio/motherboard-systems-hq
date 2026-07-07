
import assert from "node:assert/strict";

import { describe, it } from "node:test";

import Database from "better-sqlite3";

import { createOperationalIntakeRecord } from "./operational-intake-runtime";

function createTestDb() {

  const db = new Database(":memory:");

  db.pragma("foreign_keys = ON");

  db.exec(`

    CREATE TABLE governance_packages (

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      requested_outcome TEXT,

      scope TEXT,

      containment TEXT,

      constraints TEXT,

      success_criteria TEXT,

      context TEXT,

      style_presentation_intent TEXT,

      exclusions TEXT,

      created_at TEXT NOT NULL,

      PRIMARY KEY (package_id, package_version)

    );

    CREATE TABLE governance_delegations (

      delegation_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      authorization_state TEXT NOT NULL,

      authorization_timestamp TEXT NOT NULL,

      delegated_by TEXT NOT NULL,

      created_at TEXT NOT NULL,

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version)

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

        REFERENCES governance_delegations(delegation_id)

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

        REFERENCES governance_delegations(delegation_id),

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

        REFERENCES governance_delegations(delegation_id),

      FOREIGN KEY (validation_result_id)

        REFERENCES governance_validation_results(validation_result_id),

      FOREIGN KEY (envelope_gate_id)

        REFERENCES governance_envelope_gates(envelope_gate_id)

    );

    CREATE TABLE operational_intake_records (

      intake_id TEXT PRIMARY KEY,

      envelope_id TEXT NOT NULL,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      delegation_id TEXT NOT NULL,

      validation_result_id TEXT NOT NULL,

      envelope_gate_id TEXT NOT NULL,

      lifecycle_state_at_intake TEXT NOT NULL,

      assigned_department TEXT NOT NULL,

      required_capabilities_snapshot TEXT,

      intake_status TEXT NOT NULL,

      intake_created_at TEXT NOT NULL,

      intake_updated_at TEXT NOT NULL,

      governance_authority_preserved INTEGER NOT NULL,

      lifecycle_authority_preserved INTEGER NOT NULL,

      assignment_authority_preserved INTEGER NOT NULL,

      routing_authorized INTEGER NOT NULL,

      scheduler_authorized INTEGER NOT NULL,

      worker_claim_authorized INTEGER NOT NULL,

      execution_authorized INTEGER NOT NULL,

      FOREIGN KEY (envelope_id)

        REFERENCES governance_envelopes(envelope_id),

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version),

      FOREIGN KEY (delegation_id)

        REFERENCES governance_delegations(delegation_id),

      FOREIGN KEY (validation_result_id)

        REFERENCES governance_validation_results(validation_result_id),

      FOREIGN KEY (envelope_gate_id)

        REFERENCES governance_envelope_gates(envelope_gate_id)

    );

    CREATE UNIQUE INDEX idx_operational_intake_records_envelope_id

      ON operational_intake_records(envelope_id);

  `);

  return db;

}

function seedGovernanceLineage(db: any, lifecycleState = "ASSIGNED") {

  db.exec(`

    INSERT INTO governance_packages (

      package_id,

      package_version,

      requested_outcome,

      scope,

      containment,

      constraints,

      success_criteria,

      created_at

    ) VALUES (

      'pkg-intake-test',

      1,

      'Validate operational intake runtime',

      'Targeted test',

      'No downstream runtime',

      'Authority separation preserved',

      'Operational intake runtime works',

      '2026-06-29T00:00:00.000Z'

    );

    INSERT INTO governance_delegations (

      delegation_id,

      package_id,

      package_version,

      authorization_state,

      authorization_timestamp,

      delegated_by,

      created_at

    ) VALUES (

      'del-intake-test',

      'pkg-intake-test',

      1,

      'AUTHORIZED',

      '2026-06-29T00:00:00.000Z',

      'marcela',

      '2026-06-29T00:00:00.000Z'

    );

    INSERT INTO governance_validation_results (

      validation_result_id,

      package_id,

      package_version,

      delegation_id,

      validation_status,

      validation_timestamp,

      created_at

    ) VALUES (

      'val-intake-test',

      'pkg-intake-test',

      1,

      'del-intake-test',

      'VALIDATION_PASSED',

      '2026-06-29T00:00:00.000Z',

      '2026-06-29T00:00:00.000Z'

    );

    INSERT INTO governance_envelope_gates (

      envelope_gate_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      gate_status,

      gate_decision_timestamp,

      created_at

    ) VALUES (

      'gate-intake-test',

      'pkg-intake-test',

      1,

      'del-intake-test',

      'val-intake-test',

      'OPEN',

      '2026-06-29T00:00:00.000Z',

      '2026-06-29T00:00:00.000Z'

    );

  `);

  db.prepare(`

    INSERT INTO governance_envelopes (

      envelope_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      envelope_gate_id,

      validation_status,

      required_capabilities,

      operational_corridor,

      lifecycle_state,

      created_at

    ) VALUES (

      'env-intake-test',

      'pkg-intake-test',

      1,

      'del-intake-test',

      'val-intake-test',

      'gate-intake-test',

      'VALIDATION_PASSED',

      '["engineering","coordination"]',

      'Operational Intake',

      ?,

      '2026-06-29T00:00:00.000Z'

    )

  `).run(lifecycleState);

}

describe("createOperationalIntakeRecord", () => {

  it("creates an intake record for an ASSIGNED envelope", () => {

    const db = createTestDb();

    seedGovernanceLineage(db);

    const record = createOperationalIntakeRecord({

      intake_id: "intake-test-1",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      intake_created_at: "2026-06-29T00:00:00.000Z",

      db,

    });

    assert.equal(record.intake_id, "intake-test-1");

    assert.equal(record.envelope_id, "env-intake-test");

    assert.equal(record.lifecycle_state_at_intake, "ASSIGNED");

    assert.equal(record.assigned_department, "engineering");

    assert.equal(record.required_capabilities_snapshot, '["engineering","coordination"]');

    assert.equal(record.intake_status, "RECORDED");

  });

  it("rejects intake for a non-ASSIGNED envelope", () => {

    const db = createTestDb();

    seedGovernanceLineage(db, "ENVELOPE_CREATED");

    assert.throws(

      () =>

        createOperationalIntakeRecord({

          intake_id: "intake-test-1",

          envelope_id: "env-intake-test",

          assigned_department: "engineering",

          db,

        }),

      /requires envelope lifecycle_state ASSIGNED/,

    );

  });

  it("returns the existing canonical intake record for duplicate intake", () => {

    const db = createTestDb();

    seedGovernanceLineage(db);

    const first = createOperationalIntakeRecord({

      intake_id: "intake-test-1",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      intake_created_at: "2026-06-29T00:00:00.000Z",

      db,

    });

    const second = createOperationalIntakeRecord({

      intake_id: "intake-test-2",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      intake_created_at: "2026-06-29T00:01:00.000Z",

      db,

    });

    assert.equal(second.intake_id, first.intake_id);

    assert.equal(

      db.prepare("SELECT COUNT(*) AS count FROM operational_intake_records").get().count,

      1,

    );

  });

  it("preserves authority separation flags", () => {

    const db = createTestDb();

    seedGovernanceLineage(db);

    const record = createOperationalIntakeRecord({

      intake_id: "intake-test-1",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      db,

    });

    assert.equal(record.governance_authority_preserved, true);

    assert.equal(record.lifecycle_authority_preserved, true);

    assert.equal(record.assignment_authority_preserved, true);

    assert.equal(record.routing_authorized, false);

    assert.equal(record.scheduler_authorized, false);

    assert.equal(record.worker_claim_authorized, false);

    assert.equal(record.execution_authorized, false);

  });

});

