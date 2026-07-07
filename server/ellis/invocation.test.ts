
import test from "node:test";

import assert from "node:assert/strict";

import { invokeEllisFromEnvelope } from "./invocation";

test("ellis invocation adapter normalizes comma-separated envelope capabilities without actor assignment", () => {

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

    assert.equal(result.assigned_department, "engineering_planning");

    assert.equal("assigned_actor" in result, false);

  }

});

test("ellis invocation adapter normalizes array envelope capabilities", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: ["desktop_operations", "external_backup"],

      operational_corridor: "backup_only",

    },

    available_departments: ["desktop_operations"],

  });

  assert.equal(result.ok, true);

  if (result.ok) {

    assert.equal(result.assigned_department, "desktop_operations");

    assert.equal("assigned_actor" in result, false);

  }

});

test("ellis invocation adapter escalates missing envelope capability input", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: "",

      operational_corridor: "planning_only",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "assignment");

  assert.equal(result.escalation_required, true);

});

test("ellis invocation adapter escalates missing operational corridor input", () => {

  const result = invokeEllisFromEnvelope({

    envelope: {

      required_capabilities: "engineering_planning",

      operational_corridor: "",

    },

    available_departments: ["engineering_planning"],

  });

  assert.equal(result.ok, false);

  assert.equal(result.decision_type, "assignment");

  assert.equal(result.escalation_required, true);

});

