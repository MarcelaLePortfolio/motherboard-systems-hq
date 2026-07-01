
import test from "node:test";

import assert from "node:assert/strict";

import {

  composeGovernanceLifecycleAssignmentTransition,

  type GovernanceLifecyclePersistenceFunction,

} from "./governance-lifecycle-composition";

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

test("native-free lifecycle composition succeeds with injected persistence", () => {

  const result = composeGovernanceLifecycleAssignmentTransition({

    envelope_id: "env-native-free-composition-success",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "native-free lifecycle composition test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    department_handshake: {

      acknowledgement_status: "ACKNOWLEDGED",

      capability_status: "CAPABILITY_CONFIRMED",

      response_basis: "test department acknowledged assignment readiness",

    },

    persist: fakePersist,

  });

  assert.equal(result.ok, true);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.execution_authorized, false);

  if (!result.ok) {

    throw new Error("Expected native-free lifecycle composition to pass.");

  }

  assert.equal(result.persistence.lifecycle_state, "ASSIGNED");

  assert.equal(result.persistence.mutation_authorized, false);

  assert.equal(result.persistence.execution_authorized, false);

});

test("native-free lifecycle composition fails closed before persistence when assignment is not ready", () => {

  let persistCalled = false;

  const result = composeGovernanceLifecycleAssignmentTransition({

    envelope_id: "env-native-free-composition-assignment-blocked",

    envelope: {

      lifecycle_state: "ASSIGNED",

      required_capabilities: "engineering",

      operational_corridor: "native-free lifecycle composition test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    persist: (input) => {

      persistCalled = true;

      return fakePersist(input);

    },

  });

  assert.equal(result.ok, false);

  assert.equal(persistCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.execution_authorized, false);

});

test("native-free lifecycle composition fails closed before persistence when transition target is invalid", () => {

  let persistCalled = false;

  const result = composeGovernanceLifecycleAssignmentTransition({

    envelope_id: "env-native-free-composition-transition-blocked",

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering",

      operational_corridor: "native-free lifecycle composition test",

    },

    available_departments: ["engineering"],

    available_actors: ["cade"],

    target_lifecycle_state: "RUNNING",

    persist: (input) => {

      persistCalled = true;

      return fakePersist(input);

    },

  });

  assert.equal(result.ok, false);

  assert.equal(persistCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.execution_authorized, false);

});

test("native-free lifecycle composition fails closed for missing envelope id", () => {

  assert.throws(() => {

    composeGovernanceLifecycleAssignmentTransition({

      envelope_id: "",

      envelope: {

        lifecycle_state: "ENVELOPE_CREATED",

        required_capabilities: "engineering",

        operational_corridor: "native-free lifecycle composition test",

      },

      available_departments: ["engineering"],

      available_actors: ["cade"],

      persist: fakePersist,

    });

  }, /Missing governance lifecycle composition field: envelope_id/);

});

