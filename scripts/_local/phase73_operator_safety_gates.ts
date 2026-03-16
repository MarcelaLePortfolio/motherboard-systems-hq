/*
PHASE 73 — OPERATOR SAFETY GATES
Read-only gate evaluation layer.

STRICT:
- NO reducer mutation
- NO telemetry mutation
- NO DB writes
- NO automation authority
- Gate output is advisory only
*/

import { runOperatorGuidanceCommand } from "./phase72_operator_guidance_command";
import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";

export type OperatorActionType =
  | "CONTINUE_NARROW_WORK"
  | "RUN_DIAGNOSTICS"
  | "RUN_REPLAY_VERIFICATION"
  | "RESTORE_GOLDEN"
  | "MODIFY_PROTECTED_SURFACE"
  | "MODIFY_REDUCER_LOGIC"
  | "MODIFY_TELEMETRY_WIRING";

export type OperatorSafetyGateResult = {
  action: OperatorActionType;
  allowed: boolean;
  gate: "ALLOW" | "WARN" | "BLOCK";
  reason: string;
  requiredNextStep: string;
  guidanceState: string;
  riskLevel: "SAFE" | "CAUTION" | "RISK";
};

function isHighImpactAction(action: OperatorActionType): boolean {
  return (
    action === "RESTORE_GOLDEN" ||
    action === "MODIFY_PROTECTED_SURFACE" ||
    action === "MODIFY_REDUCER_LOGIC" ||
    action === "MODIFY_TELEMETRY_WIRING"
  );
}

function isRecoveryAction(action: OperatorActionType): boolean {
  return action === "RESTORE_GOLDEN";
}

function isVerificationAction(action: OperatorActionType): boolean {
  return (
    action === "RUN_DIAGNOSTICS" ||
    action === "RUN_REPLAY_VERIFICATION"
  );
}

export function evaluateOperatorSafetyGate(
  signals: OperatorSignals,
  action: OperatorActionType
): OperatorSafetyGateResult {
  const guidance = runOperatorGuidanceCommand(signals);

  if (guidance.riskLevel === "RISK") {
    if (isRecoveryAction(action) || isVerificationAction(action)) {
      return {
        action,
        allowed: true,
        gate: "ALLOW",
        reason: "risk_state_allows_recovery_or_verification_only",
        requiredNextStep: "Execute recovery or verification action only.",
        guidanceState: guidance.systemState,
        riskLevel: guidance.riskLevel
      };
    }

    return {
      action,
      allowed: false,
      gate: "BLOCK",
      reason: "risk_state_blocks_forward_changes",
      requiredNextStep: "Restore golden checkpoint and verify protection gates.",
      guidanceState: guidance.systemState,
      riskLevel: guidance.riskLevel
    };
  }

  if (guidance.riskLevel === "CAUTION") {
    if (isHighImpactAction(action)) {
      return {
        action,
        allowed: false,
        gate: "BLOCK",
        reason: "caution_state_blocks_high_impact_changes",
        requiredNextStep: "Run diagnostics and replay verification before high-impact work.",
        guidanceState: guidance.systemState,
        riskLevel: guidance.riskLevel
      };
    }

    if (isVerificationAction(action)) {
      return {
        action,
        allowed: true,
        gate: "ALLOW",
        reason: "caution_state_prefers_verification_actions",
        requiredNextStep: "Complete verification, then reassess.",
        guidanceState: guidance.systemState,
        riskLevel: guidance.riskLevel
      };
    }

    return {
      action,
      allowed: true,
      gate: "WARN",
      reason: "caution_state_allows_limited_progress",
      requiredNextStep: "Prefer diagnostics before continuing narrow work.",
      guidanceState: guidance.systemState,
      riskLevel: guidance.riskLevel
    };
  }

  return {
    action,
    allowed: true,
    gate: "ALLOW",
    reason: "safe_state_allows_action",
    requiredNextStep: "Proceed with one narrow change.",
    guidanceState: guidance.systemState,
    riskLevel: guidance.riskLevel
  };
}
