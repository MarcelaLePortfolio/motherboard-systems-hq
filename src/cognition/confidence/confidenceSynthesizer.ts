import {
  OPERATIONAL_CONFIDENCE_THRESHOLDS,
  OPERATIONAL_CONFIDENCE_WEIGHTS,
  type OperationalConfidence,
  type OperationalConfidenceLevel,
} from "./confidence.types";
import {
  buildOperationalConfidenceFactorExplanations,
  type OperationalConfidenceInputs,
} from "./confidenceFactors";

export function deriveOperationalConfidenceLevel(
  score: number,
): OperationalConfidenceLevel {
  if (score < OPERATIONAL_CONFIDENCE_THRESHOLDS.lowUpperExclusive) {
    return "LOW";
  }

  if (score < OPERATIONAL_CONFIDENCE_THRESHOLDS.mediumUpperExclusive) {
    return "MEDIUM";
  }

  return "HIGH";
}

export function synthesizeOperationalConfidence(
  inputs: OperationalConfidenceInputs,
): OperationalConfidence {
  const factors = buildOperationalConfidenceFactorExplanations(inputs);
  const score = factors.reduce(
    (total, factor) => total + factor.weightedContribution,
    0,
  );
  const level = deriveOperationalConfidenceLevel(score);

  return {
    score,
    level,
    thresholds: OPERATIONAL_CONFIDENCE_THRESHOLDS,
    weights: OPERATIONAL_CONFIDENCE_WEIGHTS,
    reasoning: {
      summary: factors.map(
        (factor) =>
          `${factor.factor} contributed ${factor.weightedContribution} points (${factor.score}/100 at weight ${factor.weight}).`,
      ),
      factors,
    },
  };
}
