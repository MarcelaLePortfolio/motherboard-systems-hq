
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionLifecycleEntryPoint } from "./production-lifecycle-consumer.ts";

const handshake = {

  acknowledgement_status: "ACKNOWLEDGED",

  capability_status: "CAPABILITY_CONFIRMED",

  response_basis: "Department confirms current capability.",

};

test("production lifecycle consumer invokes production entry point with injected persistence", () => {

  const result = consumeProductionLifecycleEntryPoint({

    envelope_id: "env-production-lifecycle-consumer-success",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle consumer test",

    },

    available_departments: ["engineering"],

    department_handshake: handshake,

    persist_lifecycle_transition: ({ envelope_id, transition_authorization, persisted_at }) => ({

      envelope_id,

      previous_lifecycle_state: transition_authorization.from,

      lifecycle_state: transition_authorization.to,

      assignment_state: "ASSIGNED",

      assigned_department: "engineering",

      routing_history: "production lifecycle consumer test",

      persisted_at: persisted_at ?? "2026-06-26T10:39:38.000Z",

      mutation_authorized: false,

      execution_authorized: false,

    }),

  });

  assert.equal(result.ok, true);

  if (result.ok) {

    assert.equal(result.lifecycle.persistence.lifecycle_state, "ASSIGNED");

    assert.equal(result.lifecycle.assignment_boundary.ellis_decision.assigned_department, "engineering");

    assert.equal("assigned_actor" in result.lifecycle.assignment_boundary.ellis_decision, false);

  }

});

