import type {
  MatildaConversationHistoryContextTurn,
} from "./matilda-conversation-history-context";
import type {
  MatildaContaminationEvaluatedInterpretation,
} from "./matilda-history-contamination-evaluator";

export interface MatildaSelectedHistoryTurn
  extends MatildaConversationHistoryContextTurn {}

export function selectMatildaConversationHistory(
  history: MatildaConversationHistoryContextTurn[],
  interpretations:
    MatildaContaminationEvaluatedInterpretation[],
): MatildaSelectedHistoryTurn[] {
  const eligibleTurnIds = new Set(
    interpretations
      .filter(
        (entry) =>
          entry.authorityEvaluation === "eligible" &&
          entry.contaminationEvaluation === "clear",
      )
      .map((entry) => entry.sourceTurnId),
  );

  return history.filter((turn) =>
    eligibleTurnIds.has(turn.sourceTurnId),
  );
}
