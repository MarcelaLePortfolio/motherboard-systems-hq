import { GuidanceIntent } from "./guidanceIntent.types.ts";
import { GuidancePriority } from "./guidancePriority.types.ts";

export function deriveGuidancePriority(
  intent: GuidanceIntent
): GuidancePriority {
  switch (intent) {
    case GuidanceIntent.ESCALATE:
      return GuidancePriority.CRITICAL;

    case GuidanceIntent.ACT:
      return GuidancePriority.HIGH;

    case GuidanceIntent.INVESTIGATE:
      return GuidancePriority.MEDIUM;

    case GuidanceIntent.MONITOR:
      return GuidancePriority.LOW;

    case GuidanceIntent.NONE:
    default:
      return GuidancePriority.LOW;
  }
}
