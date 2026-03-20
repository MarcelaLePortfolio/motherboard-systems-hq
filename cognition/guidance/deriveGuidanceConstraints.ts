import { GuidanceIntent } from "./guidanceIntent.types.ts";
import type { GuidanceConstraints } from "./guidanceConstraint.types.ts";

export function deriveGuidanceConstraints(
  intent: GuidanceIntent
): GuidanceConstraints {
  switch (intent) {
    case GuidanceIntent.ESCALATE:
      return {
        intent,
        prohibitedSteps: [
          "Do not ignore critical conditions",
          "Do not defer operator review",
        ],
        requiresHumanConfirmation: true,
        allowAutomation: false,
      };

    case GuidanceIntent.ACT:
      return {
        intent,
        prohibitedSteps: [
          "Do not execute without operator approval",
        ],
        requiresHumanConfirmation: true,
        allowAutomation: false,
      };

    case GuidanceIntent.INVESTIGATE:
      return {
        intent,
        prohibitedSteps: [
          "Do not assume root cause without review",
        ],
        requiresHumanConfirmation: true,
        allowAutomation: false,
      };

    case GuidanceIntent.MONITOR:
      return {
        intent,
        prohibitedSteps: [
          "Do not overreact to stable conditions",
        ],
        requiresHumanConfirmation: false,
        allowAutomation: false,
      };

    case GuidanceIntent.NONE:
    default:
      return {
        intent: GuidanceIntent.NONE,
        prohibitedSteps: [],
        requiresHumanConfirmation: false,
        allowAutomation: false,
      };
  }
}
