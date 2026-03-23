export const OPERATIONAL_CONFIDENCE_FACTOR_KEYS = [
  "governanceHealth",
  "runtimeHealth",
  "cognitionCompleteness",
  "signalConsistency",
] as const;

export type OperationalConfidenceFactorKey =
  (typeof OPERATIONAL_CONFIDENCE_FACTOR_KEYS)[number];

export const OPERATIONAL_CONFIDENCE_LEVELS = [
  "LOW",
  "MEDIUM",
  "HIGH",
] as const;

export type OperationalConfidenceLevel =
  (typeof OPERATIONAL_CONFIDENCE_LEVELS)[number];

export interface OperationalConfidenceThresholds {
  readonly lowUpperExclusive: 60;
  readonly mediumUpperExclusive: 85;
}

export interface OperationalConfidenceWeights {
  readonly governanceHealth: 30;
  readonly runtimeHealth: 25;
  readonly cognitionCompleteness: 25;
  readonly signalConsistency: 20;
}

export interface OperationalConfidenceFactorExplanation {
  readonly factor: OperationalConfidenceFactorKey;
  readonly score: number;
  readonly weight: number;
  readonly weightedContribution: number;
  readonly reason: string;
}

export interface OperationalConfidenceReasoning {
  readonly summary: readonly string[];
  readonly factors: readonly OperationalConfidenceFactorExplanation[];
}

export interface OperationalConfidence {
  readonly score: number;
  readonly level: OperationalConfidenceLevel;
  readonly thresholds: OperationalConfidenceThresholds;
  readonly weights: OperationalConfidenceWeights;
  readonly reasoning: OperationalConfidenceReasoning;
}

export const OPERATIONAL_CONFIDENCE_THRESHOLDS: OperationalConfidenceThresholds = {
  lowUpperExclusive: 60,
  mediumUpperExclusive: 85,
};

export const OPERATIONAL_CONFIDENCE_WEIGHTS: OperationalConfidenceWeights = {
  governanceHealth: 30,
  runtimeHealth: 25,
  cognitionCompleteness: 25,
  signalConsistency: 20,
};
