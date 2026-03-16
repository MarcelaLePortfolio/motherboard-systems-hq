/*
PHASE 75 — RANKED WORKFLOW HELPERS

Combine Phase 74 suggestions with Phase 75 priority scoring.
Deterministic ordering only.

STRICT:
READ ONLY
NO execution
NO reducers
NO DB
*/

import { getOperatorWorkflowSuggestions } from "./phase74_operator_workflow_helpers";
import { scoreHelperAction } from "./phase75_operator_helper_priority";
import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";

export type RankedSuggestion = {
  action: string;
  score: number;
  riskLevel: string;
  safetyGate: string;
};

export function getRankedWorkflowSuggestions(
  signals: OperatorSignals
): RankedSuggestion[] {

  const suggestions = getOperatorWorkflowSuggestions(signals);

  const ranked = suggestions.map(s => {

    const score = scoreHelperAction(
      s.suggestedAction as any,
      s.riskLevel as any
    );

    return {
      action: s.suggestedAction,
      score: score.score,
      riskLevel: s.riskLevel,
      safetyGate: s.safetyGate
    };

  });

  ranked.sort((a,b) => b.score - a.score);

  return ranked;

}
