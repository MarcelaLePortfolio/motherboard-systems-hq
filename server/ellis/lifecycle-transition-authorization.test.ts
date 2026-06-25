
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateGovernanceLifecycleAssignmentBoundary } from "./assignment-boundary";

import { authorizeGovernanceLifecycleAssignmentTransition } from "./lifecycle-transition-authorization";

function readyBoundary() {

  return evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

}

function blockedBoundary() {

  return evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

}

test("transition authorization blocks wrong lifecycle transition", () => {

  const result = authorizeGovernanceLifecycleAssignmentTransition({

    current_lifecycle_state: "VALIDATION_PASSED",

    target_lifecycle_state: "ASSIGNED",

    assignment_boundary: readyBoundary(),

  });

  assert.equal(result.ok, false);

  assert.equal(result.transition_authorized, false);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.execution_authorized, false);

});

test("transition authorization blocks when assignment boundary is not ready", () => {

  const result = authorizeGovernanceLifecycleAssignmentTransition({

    current_lifecycle_state: "ENVELOPE_CREATED",

    target_lifecycle_state: "ASSIGNED",

    assignment_boundary: blockedBoundary(),

  });

  assert.equal(result.ok, false);

  assert.equal(result.transition_authorized, false);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.execution_authorized, false);

});

test("transition authorization allows readiness without mutation", () => {

  const result = authorizeGovernanceLifecycleAssignmentTransition({

    current_lifecycle_state: "envelope created",

    target_lifecycle_state: "assigned",

    assignment_boundary: readyBoundary(),

  });

  assert.equal(result.ok, true);

  assert.equal(result.transition_authorized, true);

  assert.equal(result.transition, "ENVELOPE_CREATED_TO_ASSIGNED");

  assert.equal(result.from, "ENVELOPE_CREATED");

  assert.equal(result.to, "ASSIGNED");

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.execution_authorized, false);

});

