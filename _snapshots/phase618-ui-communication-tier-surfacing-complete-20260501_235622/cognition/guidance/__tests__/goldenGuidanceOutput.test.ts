import test from "node:test";
import assert from "node:assert/strict";

import { toGoldenGuidanceOutput } from "../goldenGuidanceOutput.ts";
import { GuidanceIntent } from "../guidanceIntent.types.ts";
import { GuidancePriority } from "../guidancePriority.types.ts";

test("toGoldenGuidanceOutput returns canonical render-safe structure", () => {
  const golden = toGoldenGuidanceOutput({
    intent: GuidanceIntent.INVESTIGATE,
    priority: GuidancePriority.MEDIUM,
    explanation: " Potential issue detected. Investigation recommended. ",
    action: {
      intent: GuidanceIntent.INVESTIGATE,
      message: " Situation requires investigation ",
      recommendedSteps: [" Review metrics ", "Check recent changes", " "],
    },
    constraints: {
      intent: GuidanceIntent.INVESTIGATE,
      prohibitedSteps: [" Do not assume root cause without review ", " "],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
  });

  assert.deepEqual(golden, {
    priority: GuidancePriority.MEDIUM,
    explanation: "Potential issue detected. Investigation recommended.",
    actionMessage: "Situation requires investigation",
    recommendedSteps: ["Review metrics", "Check recent changes"],
    prohibitedSteps: ["Do not assume root cause without review"],
    requiresHumanConfirmation: true,
    allowAutomation: false,
  });
});

test("toGoldenGuidanceOutput stabilizes empty explanation and action message", () => {
  const golden = toGoldenGuidanceOutput({
    intent: GuidanceIntent.NONE,
    priority: GuidancePriority.LOW,
    explanation: "   ",
    action: {
      intent: GuidanceIntent.NONE,
      message: "   ",
      recommendedSteps: [],
    },
    constraints: {
      intent: GuidanceIntent.NONE,
      prohibitedSteps: [],
      requiresHumanConfirmation: false,
      allowAutomation: false,
    },
  });

  assert.equal(golden.explanation, "No explanation available.");
  assert.equal(golden.actionMessage, "No action required.");
  assert.deepEqual(golden.recommendedSteps, []);
  assert.deepEqual(golden.prohibitedSteps, []);
});

test("toGoldenGuidanceOutput strips non-render behavior fields", () => {
  const golden = toGoldenGuidanceOutput({
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

  assert.equal("intent" in golden, false);
  assert.equal(golden.priority, GuidancePriority.CRITICAL);
  assert.equal(golden.requiresHumanConfirmation, true);
  assert.equal(golden.allowAutomation, false);
});
