
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateEllisDecision } from "./decision.ts";

test("Ellis decision blocks missing required capabilities", () => {

  const result = evaluateEllisDecision({

    required_capabilities: "",

    operational_corridor: "planning_only",

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.escalation_required, true);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.autonomous_authority, false);

});

test("Ellis decision blocks missing operational corridor", () => {

  const result = evaluateEllisDecision({

    required_capabilities: "engineering_planning",

    operational_corridor: "",

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.escalation_required, true);

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.autonomous_authority, false);

});

test("Ellis decision blocks when no department is available", () => {

  const result = evaluateEllisDecision({

    required_capabilities: "engineering_planning",

    operational_corridor: "planning_only",

    available_departments: [],

  });

  assert.equal(result.ok, false);

  assert.equal(result.escalation_required, true);

});

test("Ellis decision assigns department without actor assignment", () => {

  const result = evaluateEllisDecision({

    required_capabilities: "engineering_planning, repository_analysis",

    operational_corridor: "planning_only",

    available_departments: ["engineering_planning"],

    available_actors: ["cade"],

  });

  assert.equal(result.ok, true);

  assert.equal(result.decision_type, "assignment");

  if (result.ok) {

    assert.equal(result.assigned_department, "engineering_planning");

    assert.equal("assigned_actor" in result, false);

    assert.equal(result.escalation_required, false);

  }

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.autonomous_authority, false);

});

