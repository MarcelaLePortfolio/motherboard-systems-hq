export type OperationalConfidenceLevel =
  | "HIGH"
  | "MEDIUM"
  | "LOW";

export interface OperationalConfidenceContribution {
  source: string;
  confidence: OperationalConfidenceLevel;
  note?: string;
}

export interface OperationalConfidence {
  level: OperationalConfidenceLevel;
  contributions: OperationalConfidenceContribution[];
}
