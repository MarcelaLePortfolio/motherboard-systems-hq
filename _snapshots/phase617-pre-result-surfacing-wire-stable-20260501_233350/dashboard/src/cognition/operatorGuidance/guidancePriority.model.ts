import { scoreToPriority } from "./guidancePriority.thresholds";

export enum GuidancePriority {
  HIGH = "HIGH",
  MED = "MED",
  LOW = "LOW"
}

export type GuidanceSeverity = "HIGH" | "MED" | "LOW";
export type GuidanceConfidence = "HIGH" | "MED" | "LOW";

const severityWeight = {
  HIGH: 3,
  MED: 2,
  LOW: 1
} as const;

const confidenceWeight = {
  HIGH: 3,
  MED: 2,
  LOW: 1
} as const;

export function computePriorityScore(
  severity: GuidanceSeverity,
  confidence: GuidanceConfidence
): number {
  return (severityWeight[severity] * 2) + confidenceWeight[confidence];
}

export function derivePriority(
  severity: GuidanceSeverity,
  confidence: GuidanceConfidence
): GuidancePriority {
  const score = computePriorityScore(severity, confidence);
  return scoreToPriority(score);
}
