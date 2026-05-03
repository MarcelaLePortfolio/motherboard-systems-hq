import type { GuidanceAction } from "./guidanceAction.types.ts";
import type { GuidanceConstraints } from "./guidanceConstraint.types.ts";
import type { GuidanceOutput } from "./guidanceOutput.types.ts";
import type { GuidanceIntent } from "./guidanceIntent.types.ts";
import type { GuidancePriority } from "./guidancePriority.types.ts";

function stableStringArray(values: string[]): string[] {
  return [...values].map((value) => value.trim()).filter(Boolean);
}

function normalizeAction(action: GuidanceAction): GuidanceAction {
  return {
    intent: action.intent,
    message: action.message.trim(),
    recommendedSteps: stableStringArray(action.recommendedSteps),
  };
}

function normalizeConstraints(
  constraints: GuidanceConstraints
): GuidanceConstraints {
  return {
    intent: constraints.intent,
    prohibitedSteps: stableStringArray(constraints.prohibitedSteps),
    requiresHumanConfirmation: constraints.requiresHumanConfirmation,
    allowAutomation: constraints.allowAutomation,
  };
}

export function composeGuidanceOutput(args: {
  intent: GuidanceIntent;
  priority: GuidancePriority;
  explanation: string;
  action: GuidanceAction;
  constraints: GuidanceConstraints;
}): GuidanceOutput {
  return {
    intent: args.intent,
    priority: args.priority,
    explanation: args.explanation.trim(),
    action: normalizeAction(args.action),
    constraints: normalizeConstraints(args.constraints),
  };
}
