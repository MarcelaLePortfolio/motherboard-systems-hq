
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionEnvelopeGateEntryPoint } from "./production-envelope-gate-consumer";

test("production Envelope Gate consumer invokes Envelope Gate entry point with injected persistence", () => {

  const result = consumeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: "gate-consumer-success",

    package_id: "pkg-gate-consumer-success",

    package_version: 1,

    delegation_id: "delegation-gate-consumer-success",

    validation_result_id: "validation-gate-consumer-success",

    gate_status: "OPEN",

    gate_decision_timestamp: "2026-06-26T23:32:52.000Z",

    create_governance_envelope_gate: (input) => ({

      envelope_gate_id: input.envelope_gate_id,

      package_id: input.package_id,

      package_version: input.package_version,

      delegation_id: input.delegation_id,

      validation_result_id: input.validation_result_id,

      gate_status: input.gate_status,

      gate_decision_timestamp:

        input.gate_decision_timestamp ?? "2026-06-26T23:32:52.000Z",

      created_at: "2026-06-26T23:32:52.000Z",

    }),

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_envelope_gate_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production Envelope Gate consumer fails closed before Envelope creation authority", () => {

  const result = consumeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: "gate-consumer-fail",

    package_id: "pkg-gate-consumer-fail",

    package_version: 1,

    delegation_id: "delegation-gate-consumer-fail",

    validation_result_id: "validation-gate-consumer-fail",

    gate_status: "",

    create_governance_envelope_gate: () => {

      throw new Error("gate_status is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_envelope_gate_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

