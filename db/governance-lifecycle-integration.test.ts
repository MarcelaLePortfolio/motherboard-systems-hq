
import test from "node:test";

import assert from "node:assert/strict";

import Database from "better-sqlite3";

import { completeGovernanceLifecycleAssignmentTransition } from "./governance-lifecycle-integration";

function createTestDb() {

  const sqlite = new Database(":memory:");

  sqlite.exec(`

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

      created_at TEXT NOT NULL

    );

  `);

  return sqlite;

}

function insertEnvelope(sqlite: any, envelopeId: string, lifecycleState: string) {

  sqlite

    .prepare(`

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

        @envelope_id,

        'pkg',

        1,

        'delegation',

        'validation',

        'gate',

        'VALIDATION_PASSED',

        'engineering_planning',

        'planning_only',

        @lifecycle_state,

        '2026-06-25T00:00:00.000Z'

      )

    `)

    .run({

      envelope_id: envelopeId,

      lifecycle_state: lifecycleState,

    });

}

test("lifecycle integration stops before transition authorization when assignment readiness fails", () => {

  const sqlite = createTestDb();

  insertEnvelope(sqlite, "env-integration-blocked-assignment", "ENVELOPE_CREATED");

  const result = completeGovernanceLifecycleAssignmentTransition({

    envelope_id: "env-integration-blocked-assignment",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    db: sqlite,

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_boundary.ok, false);

  assert.equal(result.transition_authorization, undefined);

  assert.equal(result.production_runtime_caller, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.execution_authorized, false);

  const row = sqlite

    .prepare("SELECT lifecycle_state FROM governance_envelopes WHERE envelope_id = ?")

    .get("env-integration-blocked-assignment") as { lifecycle_state: string };

  assert.equal(row.lifecycle_state, "ENVELOPE_CREATED");

});

test("lifecycle integration stops before persistence when transition authorization fails", () => {

  const sqlite = createTestDb();

  insertEnvelope(sqlite, "env-integration-blocked-transition", "ENVELOPE_CREATED");

  const result = completeGovernanceLifecycleAssignmentTransition({

    envelope_id: "env-integration-blocked-transition",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    department_handshake: {

      acknowledgement_status: "ACKNOWLEDGED",

      capability_status: "CAPABILITY_CONFIRMED",

      response_basis: "test department acknowledged assignment readiness",

    },

    target_lifecycle_state: "COMPLETED",

    db: sqlite,

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_boundary.ok, true);

  assert.equal(result.transition_authorization?.ok, false);

  assert.equal(result.production_runtime_caller, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.execution_authorized, false);

  const row = sqlite

    .prepare("SELECT lifecycle_state FROM governance_envelopes WHERE envelope_id = ?")

    .get("env-integration-blocked-transition") as { lifecycle_state: string };

  assert.equal(row.lifecycle_state, "ENVELOPE_CREATED");

});

test("lifecycle integration completes assignment transition without production runtime wiring", () => {

  const sqlite = createTestDb();

  insertEnvelope(sqlite, "env-integration-complete", "ENVELOPE_CREATED");

  const result = completeGovernanceLifecycleAssignmentTransition({

    envelope_id: "env-integration-complete",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    available_actors: ["cade"],

    department_handshake: {

      acknowledgement_status: "ACKNOWLEDGED",

      capability_status: "CAPABILITY_CONFIRMED",

      response_basis: "test department acknowledged assignment readiness",

    },

    persisted_at: "2026-06-25T19:00:00.000Z",

    db: sqlite,

  });

  assert.equal(result.ok, true);

  assert.equal(result.assignment_boundary.ok, true);

  assert.equal(result.transition_authorization.ok, true);

  assert.equal(result.persistence.lifecycle_state, "ASSIGNED");

  assert.equal(result.persistence.persisted_at, "2026-06-25T19:00:00.000Z");

  assert.equal(result.production_runtime_caller, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.execution_authorized, false);

  const row = sqlite

    .prepare("SELECT lifecycle_state FROM governance_envelopes WHERE envelope_id = ?")

    .get("env-integration-complete") as { lifecycle_state: string };

  assert.equal(row.lifecycle_state, "ASSIGNED");

});

