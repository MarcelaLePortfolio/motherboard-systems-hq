export type OperatorGuidanceConfidence =
  | "high"
  | "medium"
  | "low"
  | "insufficient";

export type OperatorGuidanceSeverity =
  | "info"
  | "attention"
  | "elevated"
  | "critical";

export type OperatorGuidanceDomain =
  | "system_health"
  | "throughput"
  | "latency"
  | "task_lifecycle"
  | "signal_quality"
  | "operator_awareness";

export type OperatorGuidanceType =
  | "informational"
  | "attention"
  | "elevated"
  | "critical";

export interface OperatorGuidanceItem {
  id: string;
  type: OperatorGuidanceType;
  domain: OperatorGuidanceDomain;
  severity: OperatorGuidanceSeverity;
  confidence: OperatorGuidanceConfidence;
  message: string;
  rationale: string;
  signalSource: string[];
  bounded: true;
  executionImpact: "none";
  createdAt: number;
}

export interface OperatorGuidanceEnvelope {
  guidance: OperatorGuidanceItem[];
  generatedAt: number;
  cognitionVersion: "phase_89";
  executionAuthority: "none";
}

export interface OperatorGuidanceReduction {
  envelope: OperatorGuidanceEnvelope;
  surfaceConfidence: OperatorGuidanceConfidence;
  confidenceReason: string;
  signalCount: number;
  conflictingSignals: boolean;
}

export interface OperatorGuidanceStreamEvent {
  reduction: OperatorGuidanceReduction;
  source: string;
  ts: number;
}

export interface OperatorGuidanceRenderItem {
  id: string;
  domainLabel: string;
  severity: OperatorGuidanceSeverity;
  confidence: OperatorGuidanceConfidence;
  message: string;
  rationale: string;
  sources: string[];
  createdAtLabel: string;
}

export interface OperatorGuidanceRenderModel {
  title: string;
  generatedAtLabel: string;
  surfaceConfidence: OperatorGuidanceConfidence;
  confidenceReason: string;
  signalCount: number;
  conflictingSignals: boolean;
  source: string;
  items: OperatorGuidanceRenderItem[];
}

export const EMPTY_OPERATOR_GUIDANCE_REDUCTION: OperatorGuidanceReduction = {
  envelope: {
    guidance: [],
    generatedAt: 0,
    cognitionVersion: "phase_89",
    executionAuthority: "none",
  },
  surfaceConfidence: "insufficient",
  confidenceReason: "No signals available for interpretation.",
  signalCount: 0,
  conflictingSignals: false,
};

export const EMPTY_OPERATOR_GUIDANCE_STREAM_EVENT: OperatorGuidanceStreamEvent = {
  reduction: EMPTY_OPERATOR_GUIDANCE_REDUCTION,
  source: "diagnostics/system-health",
  ts: 0,
};
