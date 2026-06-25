
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateGovernanceLifecycleAssignmentBoundary } from "./assignment-boundary";

test("assignment boundary blocks non-envelope-created lifecycle state", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "VALIDATION_PASSED",

      required_capabilities: "engineering_planning",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_ready, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.execution_authorized, false);

});

test("assignment boundary blocks unresolved Ellis decision", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_ready, false);

  assert.equal(result.ellis_decision?.ok, false);

  assert.equal(result.lifecycle_transition_authorized, false);

});

test("assignment boundary returns assignment readiness without mutation", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning, repository_analysis",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    available_actors: ["cade"],

  });

  assert.equal(result.ok, true);

  assert.equal(result.assignment_ready, true);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.execution_authorized, false);

  if (result.ok) {

    assert.equal(result.ellis_decision.ok, true);

    assert.equal(result.ellis_decision.assigned_department, "engineering_planning");

    assert.equal(result.ellis_decision.assigned_actor, "cade");

  }

});

