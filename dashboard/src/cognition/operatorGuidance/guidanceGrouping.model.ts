import { GuidancePriority } from "./guidancePriority.model";
import { GuidanceConfidenceTier } from "./guidanceConfidence.model";

export type GuidanceType =
  | "HEALTH"
  | "RISK"
  | "WORKFLOW"
  | "INFORMATION";

export interface GuidanceItem {
  id: string;
  type: GuidanceType;
  priority: GuidancePriority;
  confidence: GuidanceConfidenceTier;
}

export interface GuidanceGrouped {
  HEALTH: GuidanceItem[];
  RISK: GuidanceItem[];
  WORKFLOW: GuidanceItem[];
  INFORMATION: GuidanceItem[];
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

function guidanceSort(a: GuidanceItem, b: GuidanceItem): number {
  const p = priorityRank(b.priority) - priorityRank(a.priority);
  if (p !== 0) return p;

  const c = confidenceRank(b.confidence) - confidenceRank(a.confidence);
  if (c !== 0) return c;

  return a.id.localeCompare(b.id);
}

export function groupGuidance(items: GuidanceItem[]): GuidanceGrouped {
  const grouped: GuidanceGrouped = {
    HEALTH: [],
    RISK: [],
    WORKFLOW: [],
    INFORMATION: []
  };

  for (const item of items) {
    grouped[item.type].push(item);
  }

  for (const key of Object.keys(grouped) as GuidanceType[]) {
    grouped[key].sort(guidanceSort);
  }

  return grouped;
}
