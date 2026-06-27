
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionEnvelopeEntryPoint } from "./production-envelope-consumer";

test("production Envelope consumer invokes Envelope entry point with injected persistence", () => {

  const result = consumeProductionEnvelopeEntryPoint({

    envelope_id: "envelope-consumer-success",

    package_id: "pkg-envelope-consumer-success",

    package_version: 1,

    delegation_id: "delegation-envelope-consumer-success",

    validation_result_id: "validation-envelope-consumer-success",

    envelope_gate_id: "gate-envelope-consumer-success",

    validation_status: "VALIDATION_PASSED",

    required_capabilities: "engineering",

    operational_corridor: "envelope consumer test",

    lifecycle_state: "ENVELOPE_CREATED",

    create_governance_envelope: (input) => ({

      envelope_id: input.envelope_id,

      package_id: input.package_id,

      package_version: input.package_version,

      delegation_id: input.delegation_id,

      validation_result_id: input.validation_result_id,

      envelope_gate_id: input.envelope_gate_id,

      validation_status: input.validation_status,

      lifecycle_state: input.lifecycle_state,

      created_at: "2026-06-26T23:48:49.000Z",

    }),

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_envelope_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production Envelope consumer fails closed before lifecycle transition authority", () => {

  const result = consumeProductionEnvelopeEntryPoint({

    envelope_id: "envelope-consumer-fail",

    package_id: "pkg-envelope-consumer-fail",

    package_version: 1,

    delegation_id: "delegation-envelope-consumer-fail",

    validation_result_id: "validation-envelope-consumer-fail",

    envelope_gate_id: "gate-envelope-consumer-fail",

    validation_status: "VALIDATION_PASSED",

    lifecycle_state: "",

    create_governance_envelope: () => {

      throw new Error("lifecycle_state is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_envelope_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

