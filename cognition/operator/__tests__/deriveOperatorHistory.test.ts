import test from "node:test";
import assert from "node:assert/strict";

import {
  appendOperatorHistoryEntry,
  createOperatorHistory,
} from "../deriveOperatorHistory.ts";
import { GuidancePriority } from "../../guidance/guidancePriority.types.ts";

test("operator history initializes empty", () => {
  const history = createOperatorHistory();

  assert.deepEqual(history, {
    entries: [],
  });
});

test("operator history appends stable entry", () => {
  const history = appendOperatorHistoryEntry(createOperatorHistory(), {
    surface: {
      id: "op_1",
      priority: GuidancePriority.MEDIUM,
      title: "Investigate situation",
      explanation: "Potential issue detected.",
      actionMessage: "Investigate situation",
      recommendedSteps: ["Review metrics"],
      prohibitedSteps: ["Do not ignore"],
      requiresHumanConfirmation: true,
      allowAutomation: false,
    },
    attention: {
      level: "MEDIUM",
      badge: "Attention Needed",
      emphasis: "STANDARD",
    },
    acknowledgement: {
      surfaceId: "op_1",
      acknowledged: false,
      acknowledgedAt: null,
      acknowledgedBy: null,
    },
    recordedAt: 100,
  });

  assert.equal(history.entries.length, 1);
  assert.equal(history.entries[0]?.surface.id, "op_1");
  assert.equal(history.entries[0]?.recordedAt, 100);
});

test("operator history sorts deterministically by recordedAt then surface id", () => {
  const history0 = createOperatorHistory();

  const history1 = appendOperatorHistoryEntry(history0, {
    surface: {
      id: "op_b",
      priority: GuidancePriority.LOW,
      title: "Monitor",
      explanation: "Stable",
      actionMessage: "Monitor",
      recommendedSteps: [],
      prohibitedSteps: [],
      requiresHumanConfirmation: false,
      allowAutomation: false,
    },
    attention: {
      level: "LOW",
      badge: "Monitor",
      emphasis: "SUBTLE",
    },
    acknowledgement: {
      surfaceId: "op_b",
      acknowledged: false,
      acknowledgedAt: null,
      acknowledgedBy: null,
    },
    recordedAt: 200,
  });

  const history2 = appendOperatorHistoryEntry(history1, {
    surface: {
      id: "op_a",
      priority: GuidancePriority.LOW,
      title: "Monitor",
      explanation: "Stable",
      actionMessage: "Monitor",
      recommendedSteps: [],
      prohibitedSteps: [],
      requiresHumanConfirmation: false,
      allowAutomation: false,
    },
    attention: {
      level: "LOW",
      badge: "Monitor",
      emphasis: "SUBTLE",
    },
    acknowledgement: {
      surfaceId: "op_a",
      acknowledged: false,
      acknowledgedAt: null,
      acknowledgedBy: null,
    },
    recordedAt: 200,
  });

  assert.deepEqual(
    history2.entries.map((entry) => entry.surface.id),
    ["op_a", "op_b"]
  );
});
