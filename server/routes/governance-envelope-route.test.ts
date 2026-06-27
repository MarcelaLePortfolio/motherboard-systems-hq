
import test from "node:test";

import assert from "node:assert/strict";

import {

  buildGovernanceEnvelopeRouteRequest,

  handleGovernanceEnvelopeRouteRequest,

} from "./governance-envelope-route";

test("governance Envelope route request builder normalizes body without adding authority", () => {

  const request = buildGovernanceEnvelopeRouteRequest({

    envelope_id: "envelope-route-builder",

    package_id: "pkg-envelope-route-builder",

    package_version: 1,

    delegation_id: "delegation-envelope-route-builder",

    validation_result_id: "validation-envelope-route-builder",

    envelope_gate_id: "gate-envelope-route-builder",

    validation_status: "VALIDATION_PASSED",

    required_capabilities: "engineering",

    operational_corridor: "envelope route test",

    lifecycle_state: "ENVELOPE_CREATED",

  });

  assert.equal(request.envelope_id, "envelope-route-builder");

  assert.equal(request.package_id, "pkg-envelope-route-builder");

  assert.equal(request.package_version, 1);

  assert.equal(request.delegation_id, "delegation-envelope-route-builder");

  assert.equal(request.validation_result_id, "validation-envelope-route-builder");

  assert.equal(request.envelope_gate_id, "gate-envelope-route-builder");

  assert.equal(request.lifecycle_state, "ENVELOPE_CREATED");

});

test("governance Envelope route handler invokes Envelope consumer with injected persistence", () => {

  const result = handleGovernanceEnvelopeRouteRequest(

    {

      envelope_id: "envelope-route-success",

      package_id: "pkg-envelope-route-success",

      package_version: 1,

      delegation_id: "delegation-envelope-route-success",

      validation_result_id: "validation-envelope-route-success",

      envelope_gate_id: "gate-envelope-route-success",

      validation_status: "VALIDATION_PASSED",

      required_capabilities: "engineering",

      operational_corridor: "envelope route test",

      lifecycle_state: "ENVELOPE_CREATED",

    },

    {

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

    },

  );

  assert.equal(result.ok, true);

  assert.equal(result.route, "governance_envelope_route");

  assert.equal(result.endpoint_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) assert.fail("Expected governance Envelope route to succeed.");

  assert.equal(result.envelope.envelope.envelope_id, "envelope-route-success");

});

test("governance Envelope route handler fails closed", () => {

  let createCalled = false;

  const result = handleGovernanceEnvelopeRouteRequest(

    {

      envelope_id: "",

      package_id: "pkg-envelope-route-fail",

      package_version: 1,

      delegation_id: "delegation-envelope-route-fail",

      validation_result_id: "validation-envelope-route-fail",

      envelope_gate_id: "gate-envelope-route-fail",

      validation_status: "VALIDATION_PASSED",

      lifecycle_state: "ENVELOPE_CREATED",

    },

    {

      create_governance_envelope: () => {

        createCalled = true;

        throw new Error("envelope_id is required");

      },

    },

  );

  assert.equal(createCalled, true);

  assert.equal(result.ok, false);

  assert.equal(result.route, "governance_envelope_route");

  assert.equal(result.endpoint_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

