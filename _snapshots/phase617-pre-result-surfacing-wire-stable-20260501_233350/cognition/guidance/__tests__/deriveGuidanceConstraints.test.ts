import test from "node:test";
import assert from "node:assert/strict";

import { deriveGuidanceConstraints } from "../deriveGuidanceConstraints.ts";
import { GuidanceIntent } from "../guidanceIntent.types.ts";

test("ESCALATE requires human confirmation and blocks automation", () => {
  const constraints = deriveGuidanceConstraints(GuidanceIntent.ESCALATE);

  assert.equal(constraints.intent, GuidanceIntent.ESCALATE);
  assert.equal(constraints.requiresHumanConfirmation, true);
  assert.equal(constraints.allowAutomation, false);
  assert.ok(constraints.prohibitedSteps.length > 0);
});

test("MONITOR remains non-automated without human confirmation requirement", () => {
  const constraints = deriveGuidanceConstraints(GuidanceIntent.MONITOR);

  assert.equal(constraints.intent, GuidanceIntent.MONITOR);
  assert.equal(constraints.requiresHumanConfirmation, false);
  assert.equal(constraints.allowAutomation, false);
});

test("NONE remains empty and non-automated", () => {
  const constraints = deriveGuidanceConstraints(GuidanceIntent.NONE);

  assert.equal(constraints.intent, GuidanceIntent.NONE);
  assert.deepEqual(constraints.prohibitedSteps, []);
  assert.equal(constraints.requiresHumanConfirmation, false);
  assert.equal(constraints.allowAutomation, false);
});
