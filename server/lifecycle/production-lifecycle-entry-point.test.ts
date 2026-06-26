
import test from "node:test";

import assert from "node:assert/strict";

import Database from "better-sqlite3";

import { invokeProductionLifecycleEntryPoint } from "./production-lifecycle-entry-point";

function createTestDb(): Database.Database {

  const sqlite = new Database(":memory:");

  sqlite.exec(`

    CREATE TABLE governance_envelopes (

      envelope_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL DEFAULT 'pkg-test',

      package_version INTEGER NOT NULL DEFAULT 1,

      delegation_id TEXT NOT NULL DEFAULT 'delegation-test',

      validation_result_id TEXT NOT NULL DEFAULT 'validation-test',

      envelope_gate_id TEXT NOT NULL DEFAULT 'gate-test',

      validation_status TEXT NOT NULL DEFAULT 'VALIDATION_PASSED',

      lifecycle_state TEXT NOT NULL,

      required_capabilities TEXT NOT NULL DEFAULT 'engineering',

      operational_corridor TEXT NOT NULL DEFAULT 'production lifecycle entry point test',

      created_at TEXT NOT NULL DEFAULT '2026-06-25T00:00:00.000Z',

      updated_at TEXT NOT NULL DEFAULT '2026-06-25T00:00:00.000Z'

    );

  `);

  return sqlite;

}

function insertEnvelope(sqlite: Database.Database, envelopeId: string, lifecycleState: string) {

  sqlite

    .prepare(

      `

        INSERT INTO governance_envelopes (

          envelope_id,

          lifecycle_state,

          required_capabilities,

          operational_corridor

        )

        VALUES (

          @envelope_id,

          @lifecycle_state,

          @required_capabilities,

          @operational_corridor

        )

      `,

    )

    .run({

      envelope_id: envelopeId,

      lifecycle_state: lifecycleState,

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    });

}

test("production lifecycle entry point delegates to existing lifecycle integration caller", () => {

  const sqlite = createTestDb();

  const envelopeId = "env-production-entry-point-success";

  insertEnvelope(sqlite, envelopeId, "ENVELOPE_CREATED");

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: envelopeId,

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    db: sqlite,

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_lifecycle_entry_point");

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) {

    throw new Error("Expected production lifecycle entry point success.");

  }

  assert.equal(result.lifecycle.ok, true);

  assert.equal(result.lifecycle.persistence.lifecycle_state, "ASSIGNED");

  const row = sqlite

    .prepare("SELECT lifecycle_state FROM governance_envelopes WHERE envelope_id = ?")

    .get(envelopeId) as { lifecycle_state: string };

  assert.equal(row.lifecycle_state, "ASSIGNED");

});

test("production lifecycle entry point fails closed for non-ENVELOPE_CREATED lifecycle state", () => {

  const sqlite = createTestDb();

  const envelopeId = "env-production-entry-point-blocked-state";

  insertEnvelope(sqlite, envelopeId, "ASSIGNED");

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: envelopeId,

    envelope: {

      lifecycle_state: "ASSIGNED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    db: sqlite,

  });

  assert.equal(result.ok, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production lifecycle entry point fails closed for missing required capabilities", () => {

  const sqlite = createTestDb();

  const envelopeId = "env-production-entry-point-missing-capabilities";

  insertEnvelope(sqlite, envelopeId, "ENVELOPE_CREATED");

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: envelopeId,

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    db: sqlite,

  });

  assert.equal(result.ok, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production lifecycle entry point fails closed for missing operational corridor", () => {

  const sqlite = createTestDb();

  const envelopeId = "env-production-entry-point-missing-corridor";

  insertEnvelope(sqlite, envelopeId, "ENVELOPE_CREATED");

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: envelopeId,

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    db: sqlite,

  });

  assert.equal(result.ok, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production lifecycle entry point fails closed for missing envelope id", () => {

  const sqlite = createTestDb();

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: "",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    db: sqlite,

  });

  assert.equal(result.ok, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

