
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionPackageEntryPoint } from "./production-package-consumer";

test(

  "production Package consumer invokes Package entry point with injected persistence",

  () => {

    const result = consumeProductionPackageEntryPoint({

      package_id: "pkg-production-package-consumer-success",

      package_version: 1,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      requested_outcome: "Create first canonical governance Package",

      scope: "Package consumer only",

      containment: "No downstream governance artifacts",

      constraints: "No new authority",

      success_criteria: "Package is created",

      create_governance_package: (input) => ({

        package_id: input.package_id,

        package_version: input.package_version,
        project_id: input.project_id,
        conversation_id: input.conversation_id,

        project_id: "hq",

        conversation_id: "conversation-governance-bridge",

        created_at: "2026-06-26T22:02:08.000Z",

      }),

    });

    assert.equal(result.ok, true);

    assert.equal(result.entry_point, "production_package_entry_point");

    assert.equal(result.scheduler_authorized, false);

    assert.equal(result.worker_claim_authorized, false);

    assert.equal(result.orchestration_authorized, false);

    assert.equal(result.routing_authorized, false);

    assert.equal(result.assignment_authorized, false);

    assert.equal(result.lifecycle_transition_authorized, false);

    assert.equal(result.execution_authorized, false);

    assert.equal(result.downstream_governance_authorized, false);

    assert.equal(result.new_authority_introduced, false);

  },

);

test("production Package consumer fails closed before downstream authority", () => {

  const result = consumeProductionPackageEntryPoint({

    package_id: "pkg-production-package-consumer-fail",

    package_version: 1,

    project_id: "hq",

    conversation_id: "conversation-governance-bridge",

    requested_outcome: "",

    scope: "Package consumer only",

    containment: "No downstream governance artifacts",

    constraints: "No new authority",

    success_criteria: "Package is rejected",

    create_governance_package: () => {

      throw new Error("requested_outcome is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_package_entry_point");

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

