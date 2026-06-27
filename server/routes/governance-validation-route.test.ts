
import test from "node:test";

import assert from "node:assert/strict";

import {

  buildGovernanceValidationRouteRequest,

  handleGovernanceValidationRouteRequest,

} from "./governance-validation-route";

test("governance Validation route request builder normalizes body without adding authority", () => {

  const request = buildGovernanceValidationRouteRequest({

    validation_result_id: "validation-route-builder",

    package_id: "pkg-validation-route-builder",

    package_version: 1,

    delegation_id: "delegation-validation-route-builder",

    validation_status: "VALIDATION_PASSED",

    governance_findings: "No blockers",

    operational_requirements: "None",

    capability_requirements: "engineering",

    escalations: "",

    validation_timestamp: "2026-06-26T23:18:30.000Z",

  });

  assert.equal(request.validation_result_id, "validation-route-builder");

  assert.equal(request.package_id, "pkg-validation-route-builder");

  assert.equal(request.package_version, 1);

  assert.equal(request.delegation_id, "delegation-validation-route-builder");

  assert.equal(request.validation_status, "VALIDATION_PASSED");

  assert.equal(request.escalations, null);

});

test("governance Validation route handler invokes Validation consumer with injected persistence", () => {

  const result = handleGovernanceValidationRouteRequest(

    {

      validation_result_id: "validation-route-success",

      package_id: "pkg-validation-route-success",

      package_version: 1,

      delegation_id: "delegation-validation-route-success",

      validation_status: "VALIDATION_PASSED",

      validation_timestamp: "2026-06-26T23:18:30.000Z",

    },

    {

      create_governance_validation_result: (input) => ({

        validation_result_id: input.validation_result_id,

        package_id: input.package_id,

        package_version: input.package_version,

        delegation_id: input.delegation_id,

        validation_status: input.validation_status,

        validation_timestamp:

          input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",

        created_at: "2026-06-26T23:18:30.000Z",

      }),

    },

  );

  assert.equal(result.ok, true);

  assert.equal(result.route, "governance_validation_route");

  assert.equal(result.endpoint_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.downstream_governance_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) {

    assert.fail("Expected governance Validation route to succeed.");

  }

  assert.equal(

    result.validation.validation.validation_result_id,

    "validation-route-success",

  );

});

test("governance Validation route handler fails closed", () => {

  let createCalled = false;

  const result = handleGovernanceValidationRouteRequest(

    {

      validation_result_id: "",

      package_id: "pkg-validation-route-fail",

      package_version: 1,

      delegation_id: "delegation-validation-route-fail",

      validation_status: "VALIDATION_PASSED",

    },

    {

      create_governance_validation_result: () => {

        createCalled = true;

        throw new Error("validation_result_id is required");

      },

    },

  );

  assert.equal(createCalled, true);

  assert.equal(result.ok, false);

  assert.equal(result.route, "governance_validation_route");

  assert.equal(result.endpoint_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.downstream_governance_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

