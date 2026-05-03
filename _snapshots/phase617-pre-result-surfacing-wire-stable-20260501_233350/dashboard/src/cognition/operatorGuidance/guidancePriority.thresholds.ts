import { GuidancePriority } from "./guidancePriority.model";

export const PRIORITY_THRESHOLDS = {
  HIGH: 7,
  MED: 4
} as const;

export function scoreToPriority(score: number): GuidancePriority {
  if (score >= PRIORITY_THRESHOLDS.HIGH) {
    return GuidancePriority.HIGH;
  }

  if (score >= PRIORITY_THRESHOLDS.MED) {
    return GuidancePriority.MED;
  }

  return GuidancePriority.LOW;
}
