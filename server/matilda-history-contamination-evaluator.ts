import type {
  MatildaEvaluatedInterpretationContext,
} from "./matilda-history-authority-evaluator";

export type MatildaHistoryContaminationEvaluation =
  | "clear"
  | "detected_superseded_context"
  | "unresolved";

export interface MatildaContaminationEvaluatedInterpretation
  extends MatildaEvaluatedInterpretationContext {
  contaminationEvaluation:
    MatildaHistoryContaminationEvaluation;
}

function evaluateContamination(
  interpretation:
    MatildaEvaluatedInterpretationContext,
): MatildaHistoryContaminationEvaluation {
  switch (interpretation.authorityEvaluation) {
    case "eligible":
      return "clear";

    case "ineligible_superseded":
      return "detected_superseded_context";

    default:
      return "unresolved";
  }
}

export function evaluateMatildaHistoryContamination(
  interpretations:
    MatildaEvaluatedInterpretationContext[],
): MatildaContaminationEvaluatedInterpretation[] {
  return interpretations.map(
    (interpretation) => ({
      ...interpretation,
      contaminationEvaluation:
        evaluateContamination(
          interpretation,
        ),
    }),
  );
}
