import type { OperationalConfidence } from "./confidence";

export interface OperatorGuidanceConfidenceInput {
  operationalConfidence?: OperationalConfidence;
}
/*
PHASE 89 — CONFIDENCE FRAMING MODEL
Defines bounded confidence interpretation rules.
No execution authority. Cognition framing only.
*/

import type { GuidanceConfidence } from "./operatorGuidance";
import type { GuidanceSignalObservation } from "./operatorGuidanceMapping";

export type ConfidenceAssessment = {
  confidence: GuidanceConfidence;
  reason: string;
  signalCount: number;
  conflictingSignals: boolean;
};

export function assessGuidanceConfidence(
  signals: GuidanceSignalObservation[]
): ConfidenceAssessment {

  if (signals.length === 0) {
    return {
      confidence: "insufficient",
      reason: "No signals available for interpretation.",
      signalCount: 0,
      conflictingSignals: false,
    };
  }

  const degraded = signals.filter(s => s.status === "degraded").length;
  const stalled = signals.filter(s => s.status === "stalled").length;
  const unknown = signals.filter(s => s.status === "unknown").length;
  const healthy = signals.filter(s => s.status === "healthy").length;

  const conflictingSignals =
    healthy > 0 && (degraded > 0 || stalled > 0);

  if (stalled > 0) {
    return {
      confidence: "medium",
      reason: "Stalled signals observed but root cause not proven.",
      signalCount: signals.length,
      conflictingSignals,
    };
  }

  if (degraded > 0) {
    return {
      confidence: "medium",
      reason: "Degraded signals observed without systemic failure.",
      signalCount: signals.length,
      conflictingSignals,
    };
  }

  if (unknown > 0) {
    return {
      confidence: "low",
      reason: "Signal quality insufficient for strong interpretation.",
      signalCount: signals.length,
      conflictingSignals,
    };
  }

  return {
    confidence: "high",
    reason: "Signals consistently indicate healthy state.",
    signalCount: signals.length,
    conflictingSignals,
  };
}

export const CONFIDENCE_MODEL_VERSION = "phase_89" as const;



export function mapOperationalConfidenceToGuidanceModifier(
  confidence?: OperationalConfidence,
): number {
  if (!confidence) return 0;

  if (confidence.level === "HIGH") return 1;
  if (confidence.level === "MEDIUM") return 0;
  if (confidence.level === "LOW") return -1;

  return 0;
}


export function confidencePriorityWeight(
  confidence?: OperationalConfidence,
): number {
  if (!confidence) {
    return 1;
  }

  switch (confidence.level) {
    case "HIGH":
      return 1;
    case "MEDIUM":
      return 1.1;
    case "LOW":
      return 1.25;
    default:
      return 1;
  }
}
