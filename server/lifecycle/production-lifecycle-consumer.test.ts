
import test from "node:test";

import assert from "node:assert/strict";

import {

  consumeProductionLifecycleEntryPoint,

} from "./production-lifecycle-consumer";

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

  assignment_state: "ASSIGNED",

  assigned_department: "engineering",

  assigned_actor: "cade",

  routing_history: "production lifecycle consumer test",

  persisted_at:

    persisted_at ?? "2026-06-26T10:10:29.000Z",

});

test(

  "production lifecycle consumer invokes production entry point with injected persistence",

  () => {

    const result = consumeProductionLifecycleEntryPoint({

      envelope_id: "env-production-lifecycle-consumer-success",

      envelope: {

        lifecycle_state: "ENVELOPE_CREATED",

        required_capabilities: "engineering",

        operational_corridor: "production lifecycle consumer test",

      },

      available_departments: ["engineering"],

      available_actors: ["cade"],

      persist_lifecycle_transition: fakePersist,

    });

    assert.equal(result.ok, true);

    if (!result.ok) {

      assert.fail("Expected success.");

    }

    assert.equal(result.entry_point, "production_lifecycle_entry_point");

    assert.equal(result.endpoint_authorized, false);

    assert.equal(result.scheduler_authorized, false);

    assert.equal(result.worker_claim_authorized, false);

    assert.equal(result.orchestration_authorized, false);

    assert.equal(result.routing_authorized, false);

    assert.equal(result.execution_authorized, false);

    assert.equal(result.new_authority_introduced, false);

    assert.equal(result.lifecycle.persistence.lifecycle_state, "ASSIGNED");

  },

);

test(

  "production lifecycle consumer fails closed before persistence",

  () => {

    let persistCalled = false;

    const result = consumeProductionLifecycleEntryPoint({

      envelope_id: "env-production-lifecycle-consumer-blocked",

      envelope: {

        lifecycle_state: "ASSIGNED",

        required_capabilities: "engineering",

        operational_corridor: "production lifecycle consumer test",

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

  },

);

