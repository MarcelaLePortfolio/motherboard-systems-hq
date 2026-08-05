import type {
  MatildaConversationHistoryContextTurn,
} from "./matilda-conversation-history-context";

export interface MatildaInterpretationContext {
  interpretationEntryId: string;
  sourceTurnId: string;
  supersessionStatus: "unknown";
  contaminationStatus:
    MatildaConversationHistoryContextTurn["contaminationStatus"];
}

export function buildInterpretationContext(
  history:
    MatildaConversationHistoryContextTurn[],
): MatildaInterpretationContext[] {
  return history.map((turn) => ({
    interpretationEntryId:
      turn.interpretationEntryId,
    sourceTurnId:
      turn.sourceTurnId,
    supersessionStatus: "unknown",
    contaminationStatus:
      turn.contaminationStatus,
  }));
}
