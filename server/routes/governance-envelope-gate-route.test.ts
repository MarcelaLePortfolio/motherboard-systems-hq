
import test from "node:test";

import assert from "node:assert/strict";

import {

  buildGovernanceEnvelopeGateRouteRequest,

  handleGovernanceEnvelopeGateRouteRequest,

} from "./governance-envelope-gate-route";

test("governance Envelope Gate route request builder normalizes body without adding authority", () => {

  const request = buildGovernanceEnvelopeGateRouteRequest({

    envelope_gate_id: "gate-route-builder",

    package_id: "pkg-gate-route-builder",

    package_version: 1,

    delegation_id: "delegation-gate-route-builder",

    validation_result_id: "validation-gate-route-builder",

    gate_status: "OPEN",

    gate_reason: "",

    gate_decision_timestamp: "2026-06-26T23:32:52.000Z",

  });

  assert.equal(request.envelope_gate_id, "gate-route-builder");

  assert.equal(request.package_id, "pkg-gate-route-builder");

  assert.equal(request.package_version, 1);

  assert.equal(request.delegation_id, "delegation-gate-route-builder");

  assert.equal(request.validation_result_id, "validation-gate-route-builder");

  assert.equal(request.gate_status, "OPEN");

  assert.equal(request.gate_reason, null);

});

test("governance Envelope Gate route handler invokes Envelope Gate consumer with injected persistence", () => {

  const result = handleGovernanceEnvelopeGateRouteRequest(

    {

      envelope_gate_id: "gate-route-success",

      package_id: "pkg-gate-route-success",

      package_version: 1,

      delegation_id: "delegation-gate-route-success",

      validation_result_id: "validation-gate-route-success",

      gate_status: "OPEN",

      gate_decision_timestamp: "2026-06-26T23:32:52.000Z",

    },

    {

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

    },

  );

  assert.equal(result.ok, true);

  assert.equal(result.route, "governance_envelope_gate_route");

  assert.equal(result.endpoint_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) assert.fail("Expected governance Envelope Gate route to succeed.");

  assert.equal(

    result.envelope_gate.envelope_gate.envelope_gate_id,

    "gate-route-success",

  );

});

test("governance Envelope Gate route handler fails closed", () => {

  let createCalled = false;

  const result = handleGovernanceEnvelopeGateRouteRequest(

    {

      envelope_gate_id: "",

      package_id: "pkg-gate-route-fail",

      package_version: 1,

      delegation_id: "delegation-gate-route-fail",

      validation_result_id: "validation-gate-route-fail",

      gate_status: "OPEN",

    },

    {

      create_governance_envelope_gate: () => {

        createCalled = true;

        throw new Error("envelope_gate_id is required");

      },

    },

  );

  assert.equal(createCalled, true);

  assert.equal(result.ok, false);

  assert.equal(result.route, "governance_envelope_gate_route");

  assert.equal(result.endpoint_authorized, true);

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

