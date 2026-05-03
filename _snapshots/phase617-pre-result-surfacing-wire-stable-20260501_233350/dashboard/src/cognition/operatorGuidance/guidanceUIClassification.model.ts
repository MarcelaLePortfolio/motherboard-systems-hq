import { GuidancePriority } from "./guidancePriority.model";
import { GuidanceConfidenceTier } from "./guidanceConfidence.model";
import { GuidanceType } from "./guidanceGrouping.model";

export type GuidanceDisplayIntent =
  | "CRITICAL_WARNING"
  | "CAUTION"
  | "INFORMATIONAL";

export interface GuidanceUIClass {
  badge: string;
  label: GuidanceDisplayIntent;
}

function priorityRank(priority: GuidancePriority): number {
  if (priority === GuidancePriority.HIGH) return 3;
  if (priority === GuidancePriority.MED) return 2;
  return 1;
}

function confidenceRank(conf: GuidanceConfidenceTier): number {
  if (conf === GuidanceConfidenceTier.VERY_HIGH) return 4;
  if (conf === GuidanceConfidenceTier.HIGH) return 3;
  if (conf === GuidanceConfidenceTier.MED) return 2;
  return 1;
}

export function classifyGuidanceUI(
  priority: GuidancePriority,
  confidence: GuidanceConfidenceTier,
  type: GuidanceType
): GuidanceUIClass {

  const p = priorityRank(priority);
  const c = confidenceRank(confidence);

  if (p === 3 && c >= 3 && (type === "RISK" || type === "HEALTH")) {
    return {
      badge: "guidance-badge-critical",
      label: "CRITICAL_WARNING"
    };
  }

  if (p >= 2) {
    return {
      badge: "guidance-badge-caution",
      label: "CAUTION"
    };
  }

  return {
    badge: "guidance-badge-info",
    label: "INFORMATIONAL"
  };
}
