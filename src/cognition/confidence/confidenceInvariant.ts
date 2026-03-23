import type { OperationalConfidenceInputs } from "./confidenceFactors";
import { synthesizeOperationalConfidence } from "./confidenceSynthesizer";

export const OPERATIONAL_CONFIDENCE_INVARIANT_INPUT: OperationalConfidenceInputs =
  {
    governanceHealth: { score: 100 },
    runtimeHealth: { score: 80 },
    cognitionCompleteness: { score: 80 },
    signalConsistency: { score: 75 },
  };

export function verifyOperationalConfidenceDeterminism(): void {
  const first = synthesizeOperationalConfidence(
    OPERATIONAL_CONFIDENCE_INVARIANT_INPUT,
  );
  const second = synthesizeOperationalConfidence(
    OPERATIONAL_CONFIDENCE_INVARIANT_INPUT,
  );

  const firstSerialized = JSON.stringify(first);
  const secondSerialized = JSON.stringify(second);

  if (firstSerialized !== secondSerialized) {
    throw new Error(
      "Operational confidence synthesis is non-deterministic for identical inputs.",
    );
  }

  if (first.score !== 84) {
    throw new Error(
      `Operational confidence invariant failed: expected score 84, received ${first.score}.`,
    );
  }

  if (first.level !== "MEDIUM") {
    throw new Error(
      `Operational confidence invariant failed: expected level MEDIUM, received ${first.level}.`,
    );
  }

  if (first.reasoning.factors.length !== 4) {
    throw new Error(
      `Operational confidence invariant failed: expected 4 factors, received ${first.reasoning.factors.length}.`,
    );
  }
}
