export enum GuidanceConfidenceTier {
  VERY_HIGH = "VERY_HIGH",
  HIGH = "HIGH",
  MED = "MED",
  LOW = "LOW"
}

export type SignalAgreement = "HIGH" | "MED" | "LOW";
export type MetricStability = "HIGH" | "MED" | "LOW";

const agreementWeight = {
  HIGH: 3,
  MED: 2,
  LOW: 1
} as const;

const stabilityWeight = {
  HIGH: 3,
  MED: 2,
  LOW: 1
} as const;

export function computeConfidenceScore(
  agreement: SignalAgreement,
  stability: MetricStability
): number {
  return (agreementWeight[agreement] * 2) + stabilityWeight[stability];
}

export function deriveConfidenceTier(
  agreement: SignalAgreement,
  stability: MetricStability
): GuidanceConfidenceTier {
  const score = computeConfidenceScore(agreement, stability);

  if (score >= 8) return GuidanceConfidenceTier.VERY_HIGH;
  if (score >= 6) return GuidanceConfidenceTier.HIGH;
  if (score >= 4) return GuidanceConfidenceTier.MED;
  return GuidanceConfidenceTier.LOW;
}
