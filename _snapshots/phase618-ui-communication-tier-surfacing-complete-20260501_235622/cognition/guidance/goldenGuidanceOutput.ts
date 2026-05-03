import type { GuidanceOutput } from "./guidanceOutput.types.ts";
import type { GuidancePriority } from "./guidancePriority.types.ts";

export interface GoldenGuidanceOutput {
  priority: GuidancePriority;
  explanation: string;
  actionMessage: string;
  recommendedSteps: string[];
  prohibitedSteps: string[];
  requiresHumanConfirmation: boolean;
  allowAutomation: boolean;
}

function normalizeString(value: string, fallback: string): string {
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : fallback;
}

function normalizeStringArray(values: string[]): string[] {
  return values.map((value) => value.trim()).filter(Boolean);
}

export function toGoldenGuidanceOutput(
  output: GuidanceOutput
): GoldenGuidanceOutput {
  return {
    priority: output.priority,
    explanation: normalizeString(output.explanation, "No explanation available."),
    actionMessage: normalizeString(output.action.message, "No action required."),
    recommendedSteps: normalizeStringArray(output.action.recommendedSteps),
    prohibitedSteps: normalizeStringArray(output.constraints.prohibitedSteps),
    requiresHumanConfirmation: output.constraints.requiresHumanConfirmation,
    allowAutomation: output.constraints.allowAutomation,
  };
}
