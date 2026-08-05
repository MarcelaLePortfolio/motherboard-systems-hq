import type {
  MatildaInterpretationContext,
} from "./matilda-interpretation-context-runtime";

export type MatildaHistoryAuthorityEvaluation =
  | "eligible"
  | "ineligible_superseded"
  | "unresolved";

export interface MatildaEvaluatedInterpretationContext
  extends MatildaInterpretationContext {
  authorityEvaluation:
    MatildaHistoryAuthorityEvaluation;
}

function evaluateInterpretationAuthority(
  interpretation:
    MatildaInterpretationContext,
): MatildaHistoryAuthorityEvaluation {
  switch (
    interpretation.supersessionStatus
  ) {
    case "current":
      return "eligible";

    case "superseded":
      return "ineligible_superseded";

    default:
      return "unresolved";
  }
}

export function evaluateMatildaHistoryAuthority(
  interpretations:
    MatildaInterpretationContext[],
): MatildaEvaluatedInterpretationContext[] {
  return interpretations.map(
    (interpretation) => ({
      ...interpretation,
      authorityEvaluation:
        evaluateInterpretationAuthority(
          interpretation,
        ),
    }),
  );
}
