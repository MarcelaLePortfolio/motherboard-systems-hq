/*
PHASE 75 — OPERATOR HELPER PRIORITY MODEL

Deterministic priority scoring for workflow suggestions.

STRICT:
READ ONLY
NO execution
NO reducers
NO DB
NO telemetry mutation
*/

import type { OperatorActionType } from "./phase73_operator_safety_gates";

export type PriorityScore = {
  action: OperatorActionType;
  score: number;
  reason: string;
};

function riskBasePriority(action: OperatorActionType): number {

  if (action === "RESTORE_GOLDEN") return 100;

  if (action === "RUN_DIAGNOSTICS") return 80;

  if (action === "RUN_REPLAY_VERIFICATION") return 70;

  if (action === "CONTINUE_NARROW_WORK") return 50;

  return 10;

}

export function scoreHelperAction(
  action: OperatorActionType,
  riskLevel: "SAFE" | "CAUTION" | "RISK"
): PriorityScore {

  let base = riskBasePriority(action);

  if (riskLevel === "RISK") {

    if (action === "RESTORE_GOLDEN") base += 50;

    if (action === "RUN_DIAGNOSTICS") base += 20;

  }

  if (riskLevel === "CAUTION") {

    if (action === "RUN_DIAGNOSTICS") base += 25;

    if (action === "RUN_REPLAY_VERIFICATION") base += 15;

  }

  if (riskLevel === "SAFE") {

    if (action === "CONTINUE_NARROW_WORK") base += 20;

  }

  return {
    action,
    score: base,
    reason: "deterministic_priority_model"
  };

}
