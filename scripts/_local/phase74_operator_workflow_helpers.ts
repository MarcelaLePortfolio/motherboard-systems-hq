/*
PHASE 74 — OPERATOR WORKFLOW HELPERS
Suggest safe next actions based on guidance + safety gates.

STRICT:
READ ONLY
NO execution authority
NO automation
NO reducer interaction
NO DB interaction
*/

import { runOperatorGuidanceCommand } from "./phase72_operator_guidance_command";
import { evaluateOperatorSafetyGate } from "./phase73_operator_safety_gates";
import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
import type { OperatorActionType } from "./phase73_operator_safety_gates";

export type WorkflowSuggestion = {
  suggestedAction: OperatorActionType;
  reason: string;
  safetyGate: string;
  riskLevel: string;
};

function safeSuggestions(): OperatorActionType[] {
  return [
    "CONTINUE_NARROW_WORK"
  ];
}

function cautionSuggestions(): OperatorActionType[] {
  return [
    "RUN_DIAGNOSTICS",
    "RUN_REPLAY_VERIFICATION"
  ];
}

function riskSuggestions(): OperatorActionType[] {
  return [
    "RESTORE_GOLDEN",
    "RUN_DIAGNOSTICS"
  ];
}

export function getOperatorWorkflowSuggestions(
  signals: OperatorSignals
): WorkflowSuggestion[] {

  const guidance = runOperatorGuidanceCommand(signals);

  let candidates: OperatorActionType[] = [];

  if (guidance.riskLevel === "SAFE") {
    candidates = safeSuggestions();
  }

  if (guidance.riskLevel === "CAUTION") {
    candidates = cautionSuggestions();
  }

  if (guidance.riskLevel === "RISK") {
    candidates = riskSuggestions();
  }

  return candidates.map(action => {

    const gate = evaluateOperatorSafetyGate(signals, action);

    return {
      suggestedAction: action,
      reason: gate.reason,
      safetyGate: gate.gate,
      riskLevel: gate.riskLevel
    };

  });

}
