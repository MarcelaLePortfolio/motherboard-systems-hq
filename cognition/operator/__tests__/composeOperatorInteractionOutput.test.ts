import test from "node:test";
import assert from "node:assert/strict";

import { composeOperatorInteractionOutput } from "../composeOperatorInteractionOutput.ts";
import { GuidancePriority } from "../../guidance/guidancePriority.types.ts";

test("composeOperatorInteractionOutput returns stable deterministic structure", () => {
  const output = composeOperatorInteractionOutput({
    surface: {
      id: "op_2",
      priority: GuidancePriority.MEDIUM,
      title: " Investigate situation ",
      explanation: " Potential issue detected. ",
      actionMessage: " Investigate situation ",
      recommendedSteps: [" Review metrics ", "Check recent changes", " "],
      prohibitedSteps: [" Do not ignore ", " "],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
    attention: {
      level: "MEDIUM",
      badge: " Attention Needed ",
      emphasis: "STANDARD",
    },
    acknowledgement: {
      surfaceId: "op_2",
      acknowledged: false,
      acknowledgedAt: null,
      acknowledgedBy: null,
    },
    workflow: {
      surface: {
        id: "op_2",
        priority: GuidancePriority.MEDIUM,
        title: " Investigate situation ",
        explanation: " Potential issue detected. ",
        actionMessage: " Investigate situation ",
        recommendedSteps: [" Review metrics ", "Check recent changes", " "],
        prohibitedSteps: [" Do not ignore ", " "],
        requiresHumanConfirmation: true,
        allowAutomation: false,
      },
      attention: {
        level: "MEDIUM",
        badge: " Attention Needed ",
        emphasis: "STANDARD",
      },
      acknowledgement: {
        surfaceId: "op_2",
        acknowledged: false,
        acknowledgedAt: null,
        acknowledgedBy: null,
      },
      requiresAction: true,
      readyForAutomation: false,
    },
    history: [
      {
        surface: {
          id: "op_b",
          priority: GuidancePriority.LOW,
          title: " Monitor ",
          explanation: " Stable ",
          actionMessage: " Monitor ",
          recommendedSteps: [" "],
          prohibitedSteps: [],
          requiresHumanConfirmation: false,
          allowAutomation: false,
        },
        attention: {
          level: "LOW",
          badge: " Monitor ",
          emphasis: "SUBTLE",
        },
        acknowledgement: {
          surfaceId: "op_b",
          acknowledged: false,
          acknowledgedAt: null,
          acknowledgedBy: null,
        },
        recordedAt: 200,
      },
      {
        surface: {
          id: "op_a",
          priority: GuidancePriority.LOW,
          title: " Monitor ",
          explanation: " Stable ",
          actionMessage: " Monitor ",
          recommendedSteps: [],
          prohibitedSteps: [],
          requiresHumanConfirmation: false,
          allowAutomation: false,
        },
        attention: {
          level: "LOW",
          badge: " Monitor ",
          emphasis: "SUBTLE",
        },
        acknowledgement: {
          surfaceId: "op_a",
          acknowledged: false,
          acknowledgedAt: null,
          acknowledgedBy: null,
        },
        recordedAt: 200,
      },
    ],
  });

  assert.equal(output.surface.title, "Investigate situation");
  assert.equal(output.surface.explanation, "Potential issue detected.");
  assert.deepEqual(output.surface.recommendedSteps, [
    "Review metrics",
    "Check recent changes",
  ]);
  assert.deepEqual(output.surface.prohibitedSteps, ["Do not ignore"]);
  assert.equal(output.attention.badge, "Attention Needed");
  assert.deepEqual(
    output.history.map((entry) => entry.surface.id),
    ["op_a", "op_b"]
  );
});

test("composeOperatorInteractionOutput preserves workflow booleans deterministically", () => {
  const output = composeOperatorInteractionOutput({
    surface: {
      id: "op_1",
      priority: GuidancePriority.CRITICAL,
      title: "Escalate",
      explanation: "Risk",
      actionMessage: "Escalate",
      recommendedSteps: ["Review"],
      prohibitedSteps: [],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
    attention: {
      level: "CRITICAL",
      badge: "Critical Attention",
      emphasis: "STRONG",
    },
    acknowledgement: {
      surfaceId: "op_1",
      acknowledged: false,
      acknowledgedAt: null,
      acknowledgedBy: null,
    },
    workflow: {
      surface: {
        id: "op_1",
        priority: GuidancePriority.CRITICAL,
        title: "Escalate",
        explanation: "Risk",
        actionMessage: "Escalate",
        recommendedSteps: ["Review"],
        prohibitedSteps: [],
        requiresHumanConfirmation: true,
        allowAutomation: false,
      },
      attention: {
        level: "CRITICAL",
        badge: "Critical Attention",
        emphasis: "STRONG",
      },
      acknowledgement: {
        surfaceId: "op_1",
        acknowledged: false,
        acknowledgedAt: null,
        acknowledgedBy: null,
      },
      requiresAction: true,
      readyForAutomation: false,
    },
    history: [],
  });

  assert.equal(output.workflow.requiresAction, true);
  assert.equal(output.workflow.readyForAutomation, false);
});
