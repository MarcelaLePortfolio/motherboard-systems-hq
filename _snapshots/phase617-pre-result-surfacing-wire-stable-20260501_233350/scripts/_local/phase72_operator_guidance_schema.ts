/*
PHASE 72 — GUIDANCE OUTPUT SCHEMA
Canonical read-only output model for operator guidance.
*/

export type OperatorGuidanceRiskLevel =
  | "SAFE"
  | "CAUTION"
  | "RISK";

export type OperatorGuidanceReason =
  | "system_stable"
  | "replay_drift"
  | "telemetry_gap"
  | "protection_failure"
  | "reducer_collision"
  | "diagnostics_failure";

export type OperatorGuidanceOutput = {
  systemState: string;
  riskLevel: OperatorGuidanceRiskLevel;
  recommendedAction: string;
  safeToContinue: boolean;
  blocking: boolean;
  reasons: OperatorGuidanceReason[];
};

export function createOperatorGuidanceOutput(
  input: OperatorGuidanceOutput
): OperatorGuidanceOutput {
  return {
    systemState: input.systemState,
    riskLevel: input.riskLevel,
    recommendedAction: input.recommendedAction,
    safeToContinue: input.safeToContinue,
    blocking: input.blocking,
    reasons: [...input.reasons]
  };
}
