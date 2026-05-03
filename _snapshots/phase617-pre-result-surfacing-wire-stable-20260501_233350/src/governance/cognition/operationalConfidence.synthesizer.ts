import {
  OperationalConfidence,
  OperationalConfidenceContribution,
  OperationalConfidenceLevel,
} from "./operationalConfidence.types";

function rank(level: OperationalConfidenceLevel): number {
  if (level === "HIGH") return 3;
  if (level === "MEDIUM") return 2;
  return 1;
}

function deriveLevel(
  contributions: OperationalConfidenceContribution[]
): OperationalConfidenceLevel {
  if (contributions.length === 0) return "MEDIUM";

  let min = 3;

  for (const c of contributions) {
    const r = rank(c.confidence);
    if (r < min) {
      min = r;
    }
  }

  if (min === 3) return "HIGH";
  if (min === 2) return "MEDIUM";
  return "LOW";
}

export function synthesizeOperationalConfidence(
  contributions: OperationalConfidenceContribution[]
): OperationalConfidence {
  return {
    level: deriveLevel(contributions),
    contributions,
  };
}
