import test from "node:test";
import assert from "node:assert/strict";

import { composeGuidanceOutput } from "../composeGuidanceOutput.ts";
import { GuidanceIntent } from "../guidanceIntent.types.ts";
import { GuidancePriority } from "../guidancePriority.types.ts";

test("composeGuidanceOutput returns stable deterministic structure", () => {
  const output = composeGuidanceOutput({
    intent: GuidanceIntent.INVESTIGATE,
    priority: GuidancePriority.MEDIUM,
    explanation: " Potential issue detected. Investigation recommended. ",
    action: {
      intent: GuidanceIntent.INVESTIGATE,
      message: " Situation requires investigation ",
      recommendedSteps: [" Review metrics ", "Check recent changes", "  "],
    },
    constraints: {
      intent: GuidanceIntent.INVESTIGATE,
      prohibitedSteps: [" Do not assume root cause without review ", " "],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
  });

  assert.deepEqual(output, {
    intent: GuidanceIntent.INVESTIGATE,
    priority: GuidancePriority.MEDIUM,
    explanation: "Potential issue detected. Investigation recommended.",
    action: {
      intent: GuidanceIntent.INVESTIGATE,
      message: "Situation requires investigation",
      recommendedSteps: ["Review metrics", "Check recent changes"],
    },
    constraints: {
      intent: GuidanceIntent.INVESTIGATE,
      prohibitedSteps: ["Do not assume root cause without review"],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
  });
});

test("composeGuidanceOutput preserves intent alignment across sections", () => {
  const output = composeGuidanceOutput({
    intent: GuidanceIntent.ESCALATE,
    priority: GuidancePriority.CRITICAL,
    explanation: "Critical situation detected. Immediate operator attention recommended.",
    action: {
      intent: GuidanceIntent.ESCALATE,
      message: "Immediate operator attention required",
      recommendedSteps: [
        "Review situation details",
        "Check related system signals",
        "Take corrective action",
      ],
    },
    constraints: {
      intent: GuidanceIntent.ESCALATE,
      prohibitedSteps: [
        "Do not ignore critical conditions",
        "Do not defer operator review",
      ],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
  });

  assert.equal(output.intent, output.action.intent);
  assert.equal(output.intent, output.constraints.intent);
  assert.equal(output.priority, GuidancePriority.CRITICAL);
});
