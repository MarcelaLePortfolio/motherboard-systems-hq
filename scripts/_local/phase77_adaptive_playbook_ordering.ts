/*
PHASE 77 — ADAPTIVE PLAYBOOK ORDERING

Adapt playbook step ordering based on deterministic signal severity.

STRICT:
READ ONLY
NO reducers
NO DB
NO telemetry mutation
NO UI mutation
NO execution authority
*/

import { getOperatorPlaybook } from "./phase76_operator_playbooks";
import { getSignalSeverity } from "./phase77_signal_severity_model";
import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
import type { PlaybookStep } from "./phase76_operator_playbooks";

export type AdaptiveOrderedPlaybook = {
  playbookName: string;
  severity: "NONE" | "LOW" | "MEDIUM" | "HIGH";
  orderedSteps: PlaybookStep[];
};

function uniqueSteps(steps: PlaybookStep[]): PlaybookStep[] {
  return [...new Set(steps)];
}

function reorderRecoveryPlaybook(
  severity: "NONE" | "LOW" | "MEDIUM" | "HIGH"
): PlaybookStep[] {
  if (severity === "HIGH") {
    return [
      "RUN_DIAGNOSTICS",
      "RESTORE_GOLDEN",
      "VERIFY_HEALTH",
      "CHECK_DRIFT"
    ];
  }

  return [
    "RUN_DIAGNOSTICS",
    "CHECK_DRIFT",
    "VERIFY_HEALTH",
    "RESTORE_GOLDEN"
  ];
}

function reorderDiagnosticsPlaybook(
  severity: "NONE" | "LOW" | "MEDIUM" | "HIGH"
): PlaybookStep[] {
  if (severity === "HIGH") {
    return [
      "RUN_DIAGNOSTICS",
      "VERIFY_HEALTH",
      "CHECK_DRIFT",
      "RESTORE_GOLDEN"
    ];
  }

  return [
    "RUN_DIAGNOSTICS",
    "VERIFY_HEALTH",
    "CHECK_DRIFT"
  ];
}

function reorderProgressPlaybook(
  severity: "NONE" | "LOW" | "MEDIUM" | "HIGH"
): PlaybookStep[] {
  if (severity === "HIGH") {
    return [
      "RUN_DIAGNOSTICS",
      "CONTINUE_NARROW_WORK"
    ];
  }

  return [
    "CONTINUE_NARROW_WORK"
  ];
}

export function getAdaptivePlaybookOrdering(
  signals: OperatorSignals & { healthAnomaly?: boolean }
): AdaptiveOrderedPlaybook {
  const playbook = getOperatorPlaybook(signals);
  const severity = getSignalSeverity(signals).overallSeverity;

  let orderedSteps: PlaybookStep[];

  if (playbook.name === "RECOVERY_PLAYBOOK") {
    orderedSteps = reorderRecoveryPlaybook(severity);
  } else if (playbook.name === "DIAGNOSTICS_PLAYBOOK") {
    orderedSteps = reorderDiagnosticsPlaybook(severity);
  } else {
    orderedSteps = reorderProgressPlaybook(severity);
  }

  return {
    playbookName: playbook.name,
    severity,
    orderedSteps: uniqueSteps(orderedSteps)
  };
}
