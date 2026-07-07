
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionLifecycleEntryPoint } from "./production-lifecycle-consumer";

const handshake = {

  acknowledgement_status: "ACKNOWLEDGED" as const,

  capability_status: "CAPABILITY_CONFIRMED" as const,

  response_basis: "Department confirms current capability.",

};

test("production lifecycle consumer invokes production entry point, composes operational intake, and consumes intake downstream", () => {

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

      transition: "ENVELOPE_CREATED_TO_ASSIGNED",

      persisted_at: persisted_at ?? "2026-06-26T10:39:38.000Z",

      mutation_authorized: false,

      execution_authorized: false,

    }),

    create_operational_intake: ({ intake_id, envelope_id, assigned_department, intake_created_at }) => ({

      intake_id,

      envelope_id,

      package_id: "pkg-production-lifecycle-consumer-success",

      package_version: 1,

      delegation_id: "del-production-lifecycle-consumer-success",

      validation_result_id: "val-production-lifecycle-consumer-success",

      envelope_gate_id: "gate-production-lifecycle-consumer-success",

      lifecycle_state_at_intake: "ASSIGNED",

      assigned_department,

      required_capabilities_snapshot: "engineering",

      intake_status: "RECORDED",

      intake_created_at: intake_created_at ?? "2026-06-26T10:39:38.000Z",

      intake_updated_at: intake_created_at ?? "2026-06-26T10:39:38.000Z",

      governance_authority_preserved: true,

      lifecycle_authority_preserved: true,

      assignment_authority_preserved: true,

      routing_authorized: false,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      execution_authorized: false,

    }),

  });

  assert.equal(result.ok, true);

  if (result.ok) {

    assert.equal(result.lifecycle.persistence.lifecycle_state, "ASSIGNED");

    assert.equal(result.lifecycle.assignment_boundary.ellis_decision.assigned_department, "engineering");

    assert.equal(result.operational_intake.lifecycle_state_at_intake, "ASSIGNED");

    assert.equal(result.operational_intake.assigned_department, "engineering");

    assert.equal(result.operational_intake.routing_authorized, false);

    assert.equal(result.operational_intake.scheduler_authorized, false);

    assert.equal(result.operational_intake.worker_claim_authorized, false);

    assert.equal(result.operational_intake.execution_authorized, false);

    assert.equal(result.operational_consumption.downstream_consumption_ready, true);

    assert.equal(result.operational_consumption.scheduler_authorized, false);

    assert.equal(result.operational_consumption.routing_authorized, false);

    assert.equal(result.operational_consumption.worker_claim_authorized, false);

    assert.equal(result.operational_consumption.orchestration_authorized, false);

    assert.equal(result.operational_consumption.execution_authorized, false);

    assert.equal("assigned_actor" in result.lifecycle.assignment_boundary.ellis_decision, false);

  }

});

test("production lifecycle consumer fails closed when downstream operational consumption rejects intake", () => {

  const result = consumeProductionLifecycleEntryPoint({

    envelope_id: "env-production-lifecycle-consumer-operational-reject",

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

      transition: "ENVELOPE_CREATED_TO_ASSIGNED",

      persisted_at: persisted_at ?? "2026-06-26T10:39:38.000Z",

      mutation_authorized: false,

      execution_authorized: false,

    }),

    create_operational_intake: ({ intake_id, envelope_id, assigned_department, intake_created_at }) => ({

      intake_id,

      envelope_id,

      package_id: "pkg-production-lifecycle-consumer-reject",

      package_version: 1,

      delegation_id: "del-production-lifecycle-consumer-reject",

      validation_result_id: "val-production-lifecycle-consumer-reject",

      envelope_gate_id: "gate-production-lifecycle-consumer-reject",

      lifecycle_state_at_intake: "ASSIGNED",

      assigned_department,

      required_capabilities_snapshot: "engineering",

      intake_status: "PENDING" as never,

      intake_created_at: intake_created_at ?? "2026-06-26T10:39:38.000Z",

      intake_updated_at: intake_created_at ?? "2026-06-26T10:39:38.000Z",

      governance_authority_preserved: true,

      lifecycle_authority_preserved: true,

      assignment_authority_preserved: true,

      routing_authorized: false,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      execution_authorized: false,

    }),

  });

  assert.equal(result.ok, false);

  if (!result.ok && "operational_consumption" in result) {

    assert.equal(result.operational_consumption.downstream_consumption_ready, false);

    assert.equal(result.operational_consumption.scheduler_authorized, false);

    assert.equal(result.operational_consumption.routing_authorized, false);

    assert.equal(result.operational_consumption.worker_claim_authorized, false);

    assert.equal(result.operational_consumption.orchestration_authorized, false);

    assert.equal(result.operational_consumption.execution_authorized, false);

  }

});

