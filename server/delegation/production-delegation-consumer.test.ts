
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionDelegationEntryPoint } from "./production-delegation-consumer";

test("production Delegation consumer invokes Delegation entry point with injected persistence", () => {

  const result = consumeProductionDelegationEntryPoint({

    delegation_id: "delegation-consumer-success",

    project_id: "hq",

    package_id: "pkg-delegation-consumer-success",

    package_version: 1,

    authorization_state: "AUTHORIZED",

    authorization_timestamp: "2026-06-26T22:36:27.000Z",

    delegated_by: "marcela",

    create_governance_delegation: (input) => ({

      delegation_id: input.delegation_id,

      project_id: input.project_id,

      package_id: input.package_id,

      package_version: input.package_version,

      authorization_state: input.authorization_state,

      authorization_timestamp:

        input.authorization_timestamp ?? "2026-06-26T22:36:27.000Z",

      delegated_by: input.delegated_by,

      created_at: "2026-06-26T22:36:27.000Z",

    }),

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_delegation_entry_point");

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

test("production Delegation consumer fails closed before downstream authority", () => {

  const result = consumeProductionDelegationEntryPoint({

    delegation_id: "delegation-consumer-fail",

    project_id: "hq",

    package_id: "pkg-delegation-consumer-fail",

    package_version: 1,

    authorization_state: "",

    delegated_by: "marcela",

    create_governance_delegation: () => {

      throw new Error("authorization_state is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_delegation_entry_point");

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

