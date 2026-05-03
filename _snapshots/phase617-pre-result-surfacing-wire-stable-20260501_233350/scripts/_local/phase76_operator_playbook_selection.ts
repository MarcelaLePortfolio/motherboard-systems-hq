/*
PHASE 76 — PLAYBOOK SELECTION INTEGRATION

Integrates playbook selection with ranked workflow suggestions.

STRICT:
READ ONLY
NO reducers
NO DB
NO telemetry mutation
NO UI mutation
NO execution authority
*/

import { getOperatorPlaybook } from "./phase76_operator_playbooks";
import { getRankedWorkflowSuggestions } from "./phase75_operator_ranked_helpers";
import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
import type { PlaybookStep } from "./phase76_operator_playbooks";

export type IntegratedPlaybookSelection = {
  playbookName: string;
  rankedSteps: Array<{
    step: PlaybookStep;
    score: number;
    source: "ranked_helper" | "playbook_only";
  }>;
};

function scoreForPlaybookOnlyStep(step: PlaybookStep): number {
  if (step === "RESTORE_GOLDEN") return 100;
  if (step === "RUN_DIAGNOSTICS") return 80;
  if (step === "CHECK_DRIFT") return 75;
  if (step === "VERIFY_HEALTH") return 70;
  if (step === "CONTINUE_NARROW_WORK") return 50;
  return 10;
}

export function getIntegratedPlaybookSelection(
  signals: OperatorSignals
): IntegratedPlaybookSelection {
  const playbook = getOperatorPlaybook(signals);
  const rankedHelpers = getRankedWorkflowSuggestions(signals);

  const helperScoreMap = new Map<string, number>();
  for (const helper of rankedHelpers) {
    helperScoreMap.set(helper.action, helper.score);
  }

  const rankedSteps = playbook.steps
    .map((step) => {
      const helperScore = helperScoreMap.get(step);

      if (typeof helperScore === "number") {
        return {
          step,
          score: helperScore,
          source: "ranked_helper" as const
        };
      }

      return {
        step,
        score: scoreForPlaybookOnlyStep(step),
        source: "playbook_only" as const
      };
    })
    .sort((a, b) => b.score - a.score);

  return {
    playbookName: playbook.name,
    rankedSteps
  };
}
