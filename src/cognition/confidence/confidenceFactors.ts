import type {
  OperationalConfidenceFactorExplanation,
  OperationalConfidenceFactorKey,
  OperationalConfidenceWeights,
} from "./confidence.types";
import { OPERATIONAL_CONFIDENCE_WEIGHTS } from "./confidence.types";

export interface OperationalConfidenceFactorInput {
  readonly score: number;
}

export interface OperationalConfidenceInputs {
  readonly governanceHealth: OperationalConfidenceFactorInput;
  readonly runtimeHealth: OperationalConfidenceFactorInput;
  readonly cognitionCompleteness: OperationalConfidenceFactorInput;
  readonly signalConsistency: OperationalConfidenceFactorInput;
}

export interface OperationalConfidenceFactorDescriptor {
  readonly key: OperationalConfidenceFactorKey;
  readonly weight: number;
  readonly reasonTemplate: (score: number) => string;
}

export const OPERATIONAL_CONFIDENCE_FACTOR_DESCRIPTORS: readonly OperationalConfidenceFactorDescriptor[] =
  [
    {
      key: "governanceHealth",
      weight: OPERATIONAL_CONFIDENCE_WEIGHTS.governanceHealth,
      reasonTemplate: (score) =>
        `Governance health evaluated at ${score}/100.`,
    },
    {
      key: "runtimeHealth",
      weight: OPERATIONAL_CONFIDENCE_WEIGHTS.runtimeHealth,
      reasonTemplate: (score) => `Runtime health evaluated at ${score}/100.`,
    },
    {
      key: "cognitionCompleteness",
      weight: OPERATIONAL_CONFIDENCE_WEIGHTS.cognitionCompleteness,
      reasonTemplate: (score) =>
        `Cognition completeness evaluated at ${score}/100.`,
    },
    {
      key: "signalConsistency",
      weight: OPERATIONAL_CONFIDENCE_WEIGHTS.signalConsistency,
      reasonTemplate: (score) =>
        `Signal consistency evaluated at ${score}/100.`,
    },
  ] as const;

export function clampOperationalConfidenceScore(score: number): number {
  if (Number.isNaN(score)) {
    return 0;
  }

  if (score < 0) {
    return 0;
  }

  if (score > 100) {
    return 100;
  }

  return Math.round(score);
}

export function buildOperationalConfidenceFactorExplanations(
  inputs: OperationalConfidenceInputs,
  weights: OperationalConfidenceWeights = OPERATIONAL_CONFIDENCE_WEIGHTS,
): readonly OperationalConfidenceFactorExplanation[] {
  return OPERATIONAL_CONFIDENCE_FACTOR_DESCRIPTORS.map((descriptor) => {
    const score = clampOperationalConfidenceScore(inputs[descriptor.key].score);
    const weight = weights[descriptor.key];
    const weightedContribution = Math.round((score * weight) / 100);

    return {
      factor: descriptor.key,
      score,
      weight,
      weightedContribution,
      reason: descriptor.reasonTemplate(score),
    };
  });
}
