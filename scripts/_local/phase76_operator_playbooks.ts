/*
PHASE 76 — OPERATOR PLAYBOOK DEFINITIONS

Defines deterministic operator playbooks.

STRICT RULES

READ ONLY
NO reducers
NO DB
NO telemetry mutation
NO UI mutation
*/

import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";

export type PlaybookStep =
  | "RUN_DIAGNOSTICS"
  | "VERIFY_HEALTH"
  | "CHECK_DRIFT"
  | "RESTORE_GOLDEN"
  | "CONTINUE_NARROW_WORK";

export type OperatorPlaybook = {
  name: string;
  steps: PlaybookStep[];
};

export function getOperatorPlaybook(
  signals: OperatorSignals
): OperatorPlaybook {

  if (signals.replayDrift) {

    return {
      name: "RECOVERY_PLAYBOOK",
      steps: [
        "RUN_DIAGNOSTICS",
        "CHECK_DRIFT",
        "VERIFY_HEALTH",
        "RESTORE_GOLDEN"
      ]
    };

  }

  if (signals.healthAnomaly) {

    return {
      name: "DIAGNOSTICS_PLAYBOOK",
      steps: [
        "RUN_DIAGNOSTICS",
        "VERIFY_HEALTH",
        "CHECK_DRIFT"
      ]
    };

  }

  return {

    name: "PROGRESS_PLAYBOOK",

    steps: [
      "CONTINUE_NARROW_WORK"
    ]

  };

}
