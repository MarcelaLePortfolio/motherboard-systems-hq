
import test from "node:test";

import assert from "node:assert/strict";

import {

  buildGovernanceDelegationRouteRequest,

  handleGovernanceDelegationRouteRequest,

} from "./governance-delegation-route";

test("governance Delegation route request builder normalizes body without adding authority", () => {

  const request = buildGovernanceDelegationRouteRequest({

    delegation_id: "delegation-route-builder",

    package_id: "pkg-delegation-route-builder",

    package_version: 1,

    authorization_state: "AUTHORIZED",

    authorization_timestamp: "2026-06-26T22:36:27.000Z",

    delegated_by: "marcela",

  });

  assert.equal(request.delegation_id, "delegation-route-builder");

  assert.equal(request.package_id, "pkg-delegation-route-builder");

  assert.equal(request.package_version, 1);

  assert.equal(request.authorization_state, "AUTHORIZED");

  assert.equal(request.authorization_timestamp, "2026-06-26T22:36:27.000Z");

  assert.equal(request.delegated_by, "marcela");

});

test("governance Delegation route handler invokes Delegation consumer with injected persistence", () => {

  const result = handleGovernanceDelegationRouteRequest(

    {

      delegation_id: "delegation-route-success",

      package_id: "pkg-delegation-route-success",

      package_version: 1,

      authorization_state: "AUTHORIZED",

      authorization_timestamp: "2026-06-26T22:36:27.000Z",

      delegated_by: "marcela",

    },

    {

      create_governance_delegation: (input) => ({

        delegation_id: input.delegation_id,

        package_id: input.package_id,

        package_version: input.package_version,

        authorization_state: input.authorization_state,

        authorization_timestamp:

          input.authorization_timestamp ?? "2026-06-26T22:36:27.000Z",

        delegated_by: input.delegated_by,

        created_at: "2026-06-26T22:36:27.000Z",

      }),

    },

  );

  assert.equal(result.ok, true);

  assert.equal(result.route, "governance_delegation_route");

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

    assert.fail("Expected governance Delegation route to succeed.");

  }

  assert.equal(

    result.delegation.delegation.delegation_id,

    "delegation-route-success",

  );

});

test("governance Delegation route handler fails closed", () => {

  let createCalled = false;

  const result = handleGovernanceDelegationRouteRequest(

    {

      delegation_id: "",

      package_id: "pkg-delegation-route-fail",

      package_version: 1,

      authorization_state: "AUTHORIZED",

      delegated_by: "marcela",

    },

    {

      create_governance_delegation: () => {

        createCalled = true;

        throw new Error("delegation_id is required");

      },

    },

  );

  assert.equal(createCalled, true);

  assert.equal(result.ok, false);

  assert.equal(result.route, "governance_delegation_route");

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

