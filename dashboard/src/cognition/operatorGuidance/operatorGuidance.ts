export type OperatorGuidanceConfidence = "low" | "medium" | "high";

export interface OperatorGuidanceEnvelope {
  title: string;
  summary: string;
  confidence: OperatorGuidanceConfidence;
  sources: string[];
  updatedAt: string | null;
}

export const EMPTY_OPERATOR_GUIDANCE_ENVELOPE: OperatorGuidanceEnvelope = {
  title: "Operator guidance",
  summary: "No operator guidance available.",
  confidence: "low",
  sources: [],
  updatedAt: null,
};
