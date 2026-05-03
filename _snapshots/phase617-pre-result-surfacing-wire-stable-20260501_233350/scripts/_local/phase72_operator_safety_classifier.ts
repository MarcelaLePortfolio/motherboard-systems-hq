/*
PHASE 72 — SAFETY CLASSIFICATION RULES
Deterministic safety classification layer.

STRICT:
READ ONLY
NO reducer interaction
NO DB access
PURE classification logic
*/

import {
  OperatorSignals,
  OperatorRiskLevel
} from "./phase72_operator_guidance_interpreter";

export type SafetyClassification = {
  riskLevel: OperatorRiskLevel;
  blocking: boolean;
  reason: string[];
};

export function classifyOperatorSafety(
  signals: OperatorSignals
): SafetyClassification {

  const reasons: string[] = [];

  if (signals.protectionFailure) {
    reasons.push("protection_failure");
  }

  if (signals.reducerCollision) {
    reasons.push("reducer_collision");
  }

  if (signals.diagnosticsFailure) {
    reasons.push("diagnostics_failure");
  }

  if (reasons.length > 0) {
    return {
      riskLevel: "RISK",
      blocking: true,
      reason: reasons
    };
  }

  const warnings: string[] = [];

  if (signals.replayDrift) {
    warnings.push("replay_drift");
  }

  if (signals.telemetryGap) {
    warnings.push("telemetry_gap");
  }

  if (warnings.length > 0) {
    return {
      riskLevel: "CAUTION",
      blocking: false,
      reason: warnings
    };
  }

  return {
    riskLevel: "SAFE",
    blocking: false,
    reason: ["system_stable"]
  };
}
