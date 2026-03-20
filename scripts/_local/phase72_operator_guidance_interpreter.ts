/*
PHASE 72 — OPERATOR GUIDANCE INTERPRETER
Read-only interpretation layer.

STRICT RULES:
- NO reducer mutation
- NO telemetry mutation
- NO DB writes
- READ ONLY analysis
*/

export type OperatorRiskLevel =
  | "SAFE"
  | "CAUTION"
  | "RISK";

export type OperatorGuidanceState = {
  systemState: string;
  riskLevel: OperatorRiskLevel;
  recommendedAction: string;
  safeToContinue: boolean;
};

export type OperatorSignals = {
  replayDrift?: boolean;
  reducerCollision?: boolean;
  diagnosticsFailure?: boolean;
  telemetryGap?: boolean;
  protectionFailure?: boolean;
};

export function interpretOperatorGuidance(
  signals: OperatorSignals
): OperatorGuidanceState {

  if (
    signals.protectionFailure ||
    signals.reducerCollision ||
    signals.diagnosticsFailure
  ) {
    return {
      systemState: "OPERATOR ATTENTION REQUIRED",
      riskLevel: "RISK",
      recommendedAction:
        "STOP work. Restore golden checkpoint and verify protection gates.",
      safeToContinue: false
    };
  }

  if (
    signals.replayDrift ||
    signals.telemetryGap
  ) {
    return {
      systemState: "STABLE WITH WARNINGS",
      riskLevel: "CAUTION",
      recommendedAction:
        "Run diagnostics and replay verification before continuing.",
      safeToContinue: true
    };
  }

  return {
    systemState: "STABLE",
    riskLevel: "SAFE",
    recommendedAction:
      "Safe to continue next narrow development step.",
    safeToContinue: true
  };
}

export function summarizeGuidance(
  state: OperatorGuidanceState
) {
  return {
    state: state.systemState,
    risk: state.riskLevel,
    next: state.recommendedAction,
    continue: state.safeToContinue
  };
}
