
import test from "node:test";

import assert from "node:assert/strict";

import {

  invokeProductionLifecycleEntryPoint,

} from "./production-lifecycle-entry-point";

import type {

  GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition";

const fakePersist: GovernanceLifecyclePersistenceFunction = ({

  envelope_id,

  transition_authorization,

  persisted_at,

}) => ({

  envelope_id,

  previous_lifecycle_state: transition_authorization.from,

  lifecycle_state: transition_authorization.to,

  transition: transition_authorization.transition,

  persisted_at: persisted_at?.trim() || "2026-06-25T00:00:00.000Z",

  mutation_authorized: false,

  execution_authorized: false,

});

test("production lifecycle entry point succeeds through native-free lifecycle composition", () => {

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: "env-production-entry-point-success",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    persist_lifecycle_transition: fakePersist,

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_lifecycle_entry_point");

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) {

    throw new Error("Expected production lifecycle entry point success.");

  }

  assert.equal(result.lifecycle.persistence.lifecycle_state, "ASSIGNED");

  assert.equal(result.lifecycle.persistence.mutation_authorized, false);

  assert.equal(result.lifecycle.persistence.execution_authorized, false);

});

test("production lifecycle entry point fails closed when lifecycle state is not ENVELOPE_CREATED", () => {

  let persistCalled = false;

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: "env-production-entry-point-blocked-state",

    envelope: {

      lifecycle_state: "ASSIGNED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    persist_lifecycle_transition: (input) => {

      persistCalled = true;

      return fakePersist(input);

    },

  });

  assert.equal(result.ok, false);

  assert.equal(persistCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production lifecycle entry point fails closed when required capabilities are missing", () => {

  let persistCalled = false;

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: "env-production-entry-point-missing-capabilities",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    persist_lifecycle_transition: (input) => {

      persistCalled = true;

      return fakePersist(input);

    },

  });

  assert.equal(result.ok, false);

  assert.equal(persistCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production lifecycle entry point fails closed when operational corridor is missing", () => {

  let persistCalled = false;

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: "env-production-entry-point-missing-corridor",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    persist_lifecycle_transition: (input) => {

      persistCalled = true;

      return fakePersist(input);

    },

  });

  assert.equal(result.ok, false);

  assert.equal(persistCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production lifecycle entry point fails closed when envelope id is missing", () => {

  const result = invokeProductionLifecycleEntryPoint({

    envelope_id: "",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "production lifecycle entry point test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    persist_lifecycle_transition: fakePersist,

  });

  assert.equal(result.ok, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

