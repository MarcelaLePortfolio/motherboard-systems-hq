
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateEllisDecision } from "./decision";

test("ellis decision escalates when required capabilities are missing", () => {

  const result = evaluateEllisDecision({

    required_capabilities: [],

    operational_corridor: "planning_only",

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "escalation");

  assert.equal(result.escalation_target, "Governance Validation");

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.autonomous_authority, false);

});

test("ellis decision escalates when operational corridor is missing", () => {

  const result = evaluateEllisDecision({

    required_capabilities: ["engineering_planning"],

    operational_corridor: " ",

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "escalation");

  assert.equal(result.escalation_target, "Governance Validation");

});

test("ellis decision escalates when no department is available", () => {

  const result = evaluateEllisDecision({

    required_capabilities: ["engineering_planning"],

    operational_corridor: "planning_only",

    available_departments: [],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "escalation");

});

test("ellis decision returns non-mutating assignment when capability can be resolved", () => {

  const result = evaluateEllisDecision({

    required_capabilities: ["engineering_planning", "repository_analysis"],

    operational_corridor: "planning_only",

    available_departments: ["engineering_planning"],

    available_actors: ["cade"],

  });

  assert.equal(result.ok, true);

  assert.equal(result.decision_type, "assignment");

  if (result.ok) {

    assert.equal(result.assigned_department, "engineering_planning");

    assert.equal(result.assigned_actor, "cade");

    assert.equal(result.escalation_required, false);

  }

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.autonomous_authority, false);

});

