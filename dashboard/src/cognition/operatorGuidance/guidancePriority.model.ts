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
};

const confidenceWeight = {
  HIGH: 3,
  MED: 2,
  LOW: 1
};

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

  if (score >= 7) return GuidancePriority.HIGH;
  if (score >= 4) return GuidancePriority.MED;
  return GuidancePriority.LOW;
}
