import { GuidanceIntent } from "./guidanceIntent.types.ts";

export interface GuidanceConstraints {
  intent: GuidanceIntent;
  prohibitedSteps: string[];
  requiresHumanConfirmation: boolean;
  allowAutomation: boolean;
}
