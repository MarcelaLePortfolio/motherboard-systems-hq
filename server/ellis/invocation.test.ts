
import test from "node:test";

import assert from "node:assert/strict";

import { invokeEllisFromEnvelope } from "./invocation.ts";

test("ellis invocation adapter normalizes comma-separated envelope capabilities", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: "engineering_planning, repository_analysis",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

    available_actors: ["cade"],

  });

  assert.equal(result.ok, true);

  if (result.ok) {

    assert.deepEqual(result.required_capabilities, [

      "engineering_planning",

      "repository_analysis",

    ]);

    assert.equal(result.operational_corridor, "planning_only");

    assert.equal(result.assigned_department, "engineering_planning");

    assert.equal(result.assigned_actor, "cade");

  }

  assert.equal(result.mutation_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.persistence_authorized, false);

  assert.equal(result.autonomous_authority, false);

});

test("ellis invocation adapter normalizes array envelope capabilities", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: ["desktop_operations", "external_backup"],

      operational_corridor: "desktop_operations",

    },

    available_departments: ["desktop_operations"],

  });

  assert.equal(result.ok, true);

  if (result.ok) {

    assert.deepEqual(result.required_capabilities, [

      "desktop_operations",

      "external_backup",

    ]);

    assert.equal(result.assigned_department, "desktop_operations");

  }

});

test("ellis invocation adapter escalates missing envelope capability input", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: null,

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "escalation");

  assert.equal(result.escalation_target, "Governance Validation");

});

test("ellis invocation adapter escalates missing operational corridor input", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: "engineering_planning",

      operational_corridor: " ",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "escalation");

  assert.equal(result.escalation_target, "Governance Validation");

});

