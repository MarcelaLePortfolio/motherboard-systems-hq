import test from "node:test";
import assert from "node:assert/strict";

import { deriveOperatorCognition } from "../deriveOperatorCognition.ts";
import { ConfidenceLevel } from "../../guidance/guidance.types.ts";
import { GuidanceIntent } from "../../guidance/guidanceIntent.types.ts";
import { GuidancePriority } from "../../guidance/guidancePriority.types.ts";
import { SituationCategory, SituationSeverity } from "../../situation/situation.types.ts";

test("operator cognition wires situation to operator output", () => {
  const result = deriveOperatorCognition(
    {
      classification: {
        category: SituationCategory.HEALTH,
        severity: SituationSeverity.CRITICAL,
        confidence: ConfidenceLevel.HIGH,
      },
      title: "Health risk",
      summary: "Health degradation detected",
      attentionLevel: "HIGH",
      orderHint: 1,
      context: {},
    },
    {
      intent: GuidanceIntent.ESCALATE,
      priority: GuidancePriority.CRITICAL,
      explanation: "Risk detected",
      action: {
        intent: GuidanceIntent.ESCALATE,
        message: "Escalate",
        recommendedSteps: [],
      },
      constraints: {
        intent: GuidanceIntent.ESCALATE,
        prohibitedSteps: [],
        requiresHumanConfirmation: true,
        allowAutomation: false,
      },
    }
  );

  assert.equal(result.surface.priority, GuidancePriority.CRITICAL);
  assert.equal(result.surface.title, "Health risk");
  assert.equal(result.surface.explanation, "Health degradation detected");
  assert.equal(result.workflow.requiresAction, true);
});

test("operator cognition produces deterministic stable structure", () => {
  const result = deriveOperatorCognition(
    {
      classification: {
        category: SituationCategory.INFO,
        severity: SituationSeverity.INFO,
        confidence: ConfidenceLevel.LOW,
      },
      title: "Stable",
      summary: "System stable",
      attentionLevel: "LOW",
      orderHint: 1,
      context: {},
    },
    {
      intent: GuidanceIntent.MONITOR,
      priority: GuidancePriority.LOW,
      explanation: "Stable",
      action: {
        intent: GuidanceIntent.MONITOR,
        message: "Monitor",
        recommendedSteps: [],
      },
      constraints: {
        intent: GuidanceIntent.MONITOR,
        prohibitedSteps: [],
        requiresHumanConfirmation: false,
        allowAutomation: false,
      },
    }
  );

  assert.equal(result.surface.title, "Stable");
  assert.equal(result.surface.explanation, "System stable");
  assert.equal(result.workflow.readyForAutomation, false);
});
