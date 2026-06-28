
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateGovernanceLifecycleAssignmentBoundary } from "./assignment-boundary.ts";

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

  assert.equal(result.actor_assignment_authorized, false);

  assert.equal(result.participation_resolution_authorized, false);

});

test("assignment boundary blocks unresolved Ellis decision", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    department_handshake: {

      acknowledgement_status: "ACKNOWLEDGED",

      capability_status: "CAPABILITY_CONFIRMED",

      response_basis: "Department confirms capability.",

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_ready, false);

  assert.equal(result.ellis_decision?.ok, false);

  assert.equal(result.lifecycle_transition_authorized, false);

});

test("assignment boundary requires department acknowledgement", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning, repository_analysis",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_ready, false);

  assert.equal(result.department_acknowledged, false);

  assert.equal(result.requires_ellis_recoordination, false);

});

test("assignment boundary blocks capability conflict and requires Ellis re-coordination", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning, repository_analysis",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    department_handshake: {

      acknowledgement_status: "ACKNOWLEDGED",

      capability_status: "CAPABILITY_CONFLICT_REPORTED",

      capability_conflicts: ["repository_analysis unavailable"],

      response_basis: "Department reports local operational incapacity.",

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.assignment_ready, false);

  assert.equal(result.department_acknowledged, false);

  assert.equal(result.capability_status, "CAPABILITY_CONFLICT_REPORTED");

  assert.equal(result.requires_ellis_recoordination, true);

  assert.equal(result.lifecycle_transition_authorized, false);

});

test("assignment boundary returns assignment readiness after department handshake without actor assignment", () => {

  const result = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: {

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: "engineering_planning, repository_analysis",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    department_handshake: {

      acknowledgement_status: "ACKNOWLEDGED",

      capability_status: "CAPABILITY_CONFIRMED",

      response_basis: "Department confirms current capability.",

    },

  });

  assert.equal(result.ok, true);

  assert.equal(result.assignment_ready, true);

  assert.equal(result.department_acknowledged, true);

  assert.equal(result.capability_status, "CAPABILITY_CONFIRMED");

  assert.equal(result.requires_ellis_recoordination, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.actor_assignment_authorized, false);

  assert.equal(result.participation_resolution_authorized, false);

  if (result.ok) {

    assert.equal(result.ellis_decision.ok, true);

    assert.equal(result.ellis_decision.assigned_department, "engineering_planning");

    assert.equal("assigned_actor" in result.ellis_decision, false);

  }

});

