
import test from "node:test";

import assert from "node:assert/strict";

import {

  invokeProductionDelegationEntryPoint,

  type GovernanceDelegationPersistenceFunction,

} from "./production-delegation-entry-point";

const fakeCreateDelegation: GovernanceDelegationPersistenceFunction = (input) => ({

  delegation_id: input.delegation_id,

  package_id: input.package_id,

  package_version: input.package_version,

  authorization_state: input.authorization_state,

  authorization_timestamp:

    input.authorization_timestamp ?? "2026-06-26T22:36:27.000Z",

  delegated_by: input.delegated_by,

  created_at: "2026-06-26T22:36:27.000Z",

});

test("production Delegation entry point creates only the canonical Delegation record", () => {

  const result = invokeProductionDelegationEntryPoint({

    delegation_id: "delegation-entry-point-success",

    project_id: "hq",

    package_id: "pkg-delegation-entry-point-success",

    package_version: 1,

    authorization_state: "AUTHORIZED",

    authorization_timestamp: "2026-06-26T22:36:27.000Z",

    delegated_by: "marcela",

    create_governance_delegation: fakeCreateDelegation,

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_delegation_entry_point");

  assert.equal(result.endpoint_authorized, false);

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

    assert.fail("Expected Delegation entry point to succeed.");

  }

  assert.equal(result.delegation.delegation_id, "delegation-entry-point-success");

});

test("production Delegation entry point fails closed when persistence rejects input", () => {

  const result = invokeProductionDelegationEntryPoint({

    delegation_id: "",

    package_id: "pkg-delegation-entry-point-fail",

    package_version: 1,

    authorization_state: "AUTHORIZED",

    delegated_by: "marcela",

    create_governance_delegation: () => {

      throw new Error("delegation_id is required");

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

  assert.match(result.findings.join("\n"), /delegation_id is required/);

});

