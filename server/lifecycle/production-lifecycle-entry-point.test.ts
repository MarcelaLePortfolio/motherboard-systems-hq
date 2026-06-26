
import test from "node:test";

import assert from "node:assert/strict";

import { invokeProductionLifecycleEntryPoint } from "./production-lifecycle-entry-point";

type EnvelopeRow = {

  envelope_id: string;

  lifecycle_state: string;

  required_capabilities: string;

  operational_corridor: string;

};

type FakeStatement = {

  run: (...args: unknown[]) => { changes: number };

  get: (...args: unknown[]) => unknown;

};

type FakeDb = {

  rows: Map<string, EnvelopeRow>;

  prepare: (sql: string) => FakeStatement;

};

function createTestDb(): FakeDb {

  const rows = new Map<string, EnvelopeRow>();

  return {

    rows,

    prepare(sql: string): FakeStatement {

      return {

        run(arg: unknown) {

          if (sql.includes("INSERT INTO governance_envelopes")) {

            const row = arg as EnvelopeRow;

            rows.set(row.envelope_id, {

              envelope_id: row.envelope_id,

              lifecycle_state: row.lifecycle_state,

              required_capabilities: row.required_capabilities,

              operational_corridor: row.operational_corridor,

            });

            return { changes: 1 };

          }

          if (sql.includes("UPDATE governance_envelopes")) {

            const envelopeId = String(arg);

            const row = rows.get(envelopeId);

            if (!row || row.lifecycle_state !== "ENVELOPE_CREATED") {

              return { changes: 0 };

            }

            row.lifecycle_state = "ASSIGNED";

            rows.set(envelopeId, row);

            return { changes: 1 };

          }

          throw new Error(`Unexpected fake database run SQL: ${sql}`);

        },

        get(arg: unknown) {

          if (sql.includes("SELECT lifecycle_state FROM governance_envelopes")) {

            const row = rows.get(String(arg));

            return row ? { lifecycle_state: row.lifecycle_state } : undefined;

          }

          throw new Error(`Unexpected fake database get SQL: ${sql}`);

        },

      };

    },

  };

}

function insertEnvelope(sqlite: FakeDb, envelopeId: string, lifecycleState: string) {

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

    db: sqlite as never,

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

    db: sqlite as never,

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

    db: sqlite as never,

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

    db: sqlite as never,

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

    db: sqlite as never,

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

