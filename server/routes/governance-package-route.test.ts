
import test from "node:test";

import assert from "node:assert/strict";

import {

  buildGovernancePackageRouteRequest,

  handleGovernancePackageRouteRequest,

} from "./governance-package-route";

test(

  "governance Package route request builder normalizes body without adding authority",

  () => {

    const request = buildGovernancePackageRouteRequest({

      package_id: "pkg-governance-package-route-builder",

      package_version: 1,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      requested_outcome: "Create first canonical governance Package",

      scope: "Package route only",

      containment: "No downstream governance artifacts",

      constraints: "No new authority",

      success_criteria: "Package request is normalized",

      context: "route test",

      style_presentation_intent: "plain",

      exclusions: "No Delegation",

    });

    assert.equal(request.package_id, "pkg-governance-package-route-builder");

    assert.equal(request.package_version, 1);

    assert.equal(request.requested_outcome, "Create first canonical governance Package");

    assert.equal(request.context, "route test");

    assert.equal(request.style_presentation_intent, "plain");

    assert.equal(request.exclusions, "No Delegation");

  },

);

test(

  "governance Package route handler invokes Package consumer with injected persistence",

  () => {

    const result = handleGovernancePackageRouteRequest(

      {

        package_id: "pkg-governance-package-route-success",

        package_version: 1,

        project_id: "hq",

        conversation_id: "conversation-governance-bridge",

        requested_outcome: "Create first canonical governance Package",

        scope: "Package route only",

        containment: "No downstream governance artifacts",

        constraints: "No new authority",

        success_criteria: "Package is created",

      },

      {

        create_governance_package: (input) => ({

          package_id: input.package_id,

          package_version: input.package_version,
          project_id: input.project_id,
          conversation_id: input.conversation_id,

          created_at: "2026-06-26T22:02:08.000Z",

        }),

      },

    );

    assert.equal(result.ok, true);

    assert.equal(result.route, "governance_package_route");

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

      assert.fail("Expected governance Package route to succeed.");

    }

    assert.equal(

      result.package.package.package_id,

      "pkg-governance-package-route-success",

    );

  },

);

test("governance Package route handler fails closed", () => {

  let createCalled = false;

  const result = handleGovernancePackageRouteRequest(

    {

      package_id: "",

      package_version: 1,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      requested_outcome: "Missing package id",

      scope: "Package route only",

      containment: "No downstream governance artifacts",

      constraints: "No new authority",

      success_criteria: "Package is rejected",

    },

    {

      create_governance_package: () => {

        createCalled = true;

        throw new Error("package_id is required");

      },

    },

  );

  assert.equal(createCalled, true);

  assert.equal(result.ok, false);

  assert.equal(result.route, "governance_package_route");

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

